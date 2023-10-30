//
//  LeagueDetailStandingsViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/20.
//

import UIKit

final class LeagueDetailStandingsViewController: BaseViewController, InnerScrollProvidable {
  
  let innerScroll: ScrollGestureRestrictable = {
    let view = InnerScrollTableView(frame: .zero, style: .grouped)
    view.rowHeight = 52
    view.separatorStyle = .none
    view.register(LeagueStandingsCell.self, forCellReuseIdentifier: LeagueStandingsCell.identifier)
    view.register(LeagueDetailStandingTableHeaderView.self, forHeaderFooterViewReuseIdentifier: LeagueDetailStandingTableHeaderView.identifier)
    view.allowsSelection = false
    return view
  }()
  
  let errorLabel = UILabel()
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    return view
  }()
  
  private let viewModel: LeagueDetailStandingsViewModel = LeagueDetailStandingsViewModel()
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
      case .standing(let standing):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeagueStandingsCell.identifier, for: indexPath) as? LeagueStandingsCell else { return nil }
        cell.configureView(standing: standing)
        return cell
      }
    }
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setBackgroundColor(with: .background)
    setupInnerScroll()
    setIndicator()
    
    viewModel.state.bind { [weak self] state in
      guard let self else { return }
      switch state {
      case .idle: return
      case .loading:
        showIndicator()
      case .loaded:
        hideIndicator()
        errorLabel.removeFromSuperview()
      case .error(let error):
        applySnapShot([])
        hideIndicator()
        setErrorLabel()
      case .standingsLoaded(let response):
        hideIndicator()
        isHeaderVisible = true
        applySnapShot(response)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.handle(action: .fetchStandings(season: currentSeason, id: competition.id))
    AppearanceCheck(self)
  }
  
  private func setErrorLabel() {
    errorLabel.text = LocalizedStrings.Common.dataEmpty.localizedValue
    view.addSubview(errorLabel)
    errorLabel.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
    }
  }
  
  private func setIndicator() {
    view.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
    }
  }
  
  private func showIndicator() {
    activityIndicator.startAnimating()
  }
  
  private func hideIndicator() {
    activityIndicator.stopAnimating()
  }
  
  func setupInnerScroll() {
    guard let innerScroll = innerScroll as? InnerScrollTableView else { return }
    
    view.addSubview(innerScroll)
    innerScroll.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    innerScroll.delegate = self
  }
  
  //  private func applySnapShot(_ standings: [Standing]) {
  //    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
  //    isHeaderVisible = true
  //    switch self.competition.info.cpType {
  //    case .cup:
  //      let groups = Set(standings.map { $0.group }).sorted()
  //      for group in groups {
  //        snapshot.appendSections([.group(group)])
  //        let groupStandings = standings.filter { $0.group == group }
  //        var items: [Item] = []
  //        groupStandings.forEach { standing in
  //          items.append(.standing(standing))
  //        }
  //        snapshot.appendItems(items, toSection: .group(group))
  //      }
  //
  //    case .leauge:
  //      snapshot.appendSections([.standings])
  //      var items: [Item] = []
  //      standings.forEach { standing in
  //        items.append(.standing(standing))
  //      }
  //      snapshot.appendItems(items, toSection: .standings)
  //    }
  //
  //    datasource.applySnapshotUsingReloadData(snapshot)
  //  }
  
  private func applySnapShot(_ standings: [Standing]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    let groups = Set(standings.map { $0.group }).sorted()
    
    for group in groups {
      snapshot.appendSections([.group(group)])
      
      let groupStandings = standings.filter { $0.group == group }
      let items = groupStandings.map { Item.standing($0) }
      
      snapshot.appendItems(items, toSection: .group(group))
    }
    
    datasource.applySnapshotUsingReloadData(snapshot)
  }
  
}


extension LeagueDetailStandingsViewController {
  enum Section: Hashable {
    case standings
    case group(String)
  }
  
  enum Item: Hashable {
    case standing(Standing)
  }
}

extension LeagueDetailStandingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeagueDetailStandingTableHeaderView.identifier) as? LeagueDetailStandingTableHeaderView else {
      return nil
    }
    
    guard let sectionType = datasource.snapshot().sectionIdentifiers[safe: section] else { return nil }
    
    switch sectionType {
    case .standings:
      header.configureTitleLabel(title: LocalizedStrings.Leagues.LeagueDetailTab.standingsHeader.rank.localizedValue)
    case .group(let groupName):
      header.configureTitleLabel(title: groupName)
    }
    
    return header
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return isHeaderVisible ? 62 : 0
  }
}
