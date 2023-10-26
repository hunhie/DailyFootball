//
//  LeagueDetailScorersViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/20.
//

import UIKit

final class LeagueDetailScorersViewController: BaseViewController, InnerScrollProvidable {
  
  var innerScroll: ScrollGestureRestrictable = {
    let view = InnerScrollTableView(frame: .zero, style: .grouped)
    view.rowHeight = 52
    view.separatorStyle = .none
    view.register(LeagueScorersCell.self, forCellReuseIdentifier: LeagueScorersCell.identifier)
    view.register(LeagueDetalScorersTableHeaderView.self, forHeaderFooterViewReuseIdentifier: LeagueDetalScorersTableHeaderView.identifier)
    view.allowsSelection = false
    return view
  }()
  
  private let viewModel: LeagueDetailScorersViewModel = LeagueDetailScorersViewModel()
  private let competition: Competition
  
  private lazy var currentSeason: Int = competition.season.filter { $0.current }[0].year
  private var isHeaderVisible: Bool = false
  
  init(competition: Competition) {
    self.competition = competition
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private typealias DataSource = UITableViewDiffableDataSource<Section, Item>
  private lazy var datasource: DataSource = {
    return DataSource(tableView: innerScroll as! InnerScrollTableView) { tableView, indexPath, item -> UITableViewCell? in
      switch item {
      case .scorers(let scorer):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeagueScorersCell.identifier, for: indexPath) as? LeagueScorersCell else { return nil }
        cell.configureView(scorers: scorer)
        if scorer.isTiedWithPrevious {
          cell.hideRankLabel()
        }
        return cell
      }
    }
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupInnerScroll()
    
    viewModel.state.bind { [weak self] state in
      guard let self else { return }
      switch state {
      case .idle:
        return
      case .error(let error):
        print(error)
      case .scorersLoaded(let response):
        applySnapShot(response)
      }
    }
    
    setBackgroundColor(with: .background)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    viewModel.handle(action: .fetchStandings(season: currentSeason, id: competition.id))
  }
  
  func setupInnerScroll() {
    guard let innerScroll = innerScroll as? InnerScrollTableView else { return }
    
    view.addSubview(innerScroll)
    innerScroll.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    innerScroll.delegate = self
  }
  
  func applySnapShot(_ scorers: [Scorer]) {
    isHeaderVisible = true
    
    var previousScorer: Scorer? = nil
    var scorers = scorers
    for (index, scorer) in scorers.enumerated() {
      if let previous = previousScorer, previous.goals == scorer.goals {
        scorers[index].isTiedWithPrevious = true
      } else {
        scorers[index].isTiedWithPrevious = false
      }
      previousScorer = scorer
    }
    
    var currentSnapshot = datasource.snapshot()
    currentSnapshot.deleteAllItems()
    currentSnapshot.appendSections([.scorers])
    
    var items: [Item] = []
    scorers.forEach { scorer in
      items.append(.scorers(scorer))
    }
    
    currentSnapshot.appendItems(items, toSection: .scorers)
    datasource.applySnapshotUsingReloadData(currentSnapshot)
  }
}

extension LeagueDetailScorersViewController {
  enum Section {
    case scorers
  }
  
  enum Item: Hashable {
    case scorers(Scorer)
  }
}

extension LeagueDetailScorersViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeagueDetalScorersTableHeaderView.identifier) as? LeagueDetalScorersTableHeaderView else {
      return nil
    }
    return header
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return isHeaderVisible ? 62 : 0
  }
}
