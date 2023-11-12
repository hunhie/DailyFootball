//
//  MatcheTableViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit
import RxSwift
import RxCocoa

final class MatchesTableViewController: BaseViewController {
  
  private let didToggleFixtures = PublishRelay<FixtureGroupByCompetition>()
  private let disposeBag = DisposeBag()
  
  private lazy var tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .grouped)
    view.backgroundColor = .clear
    view.separatorStyle = .none
    view.rowHeight = 52
    view.register(FixtureCell.self, forCellReuseIdentifier: FixtureCell.identifier)
    view.register(FixtureGroupCell.self, forCellReuseIdentifier: FixtureGroupCell.identifier)
    view.register(FixtureDummyCell.self, forCellReuseIdentifier: FixtureDummyCell.identifier)
    return view
  }()
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    return view
  }()
  
  private let errorLabel = UILabel()
  
  let matchesDate: MatchesViewController.MatchesDateOption
  let viewModel: MatchesViewModel
  
  init(matchesDate: MatchesViewController.MatchesDateOption, viewModel: MatchesViewModel) {
    self.viewModel = viewModel
    self.matchesDate = matchesDate
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private typealias DataSource = UITableViewDiffableDataSource<Section, Item>
  private lazy var datasource: DataSource = {
    return DataSource(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
      switch item {
      case .fixtureGroupByCompetition(let fixtureGroup):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FixtureGroupCell.identifier, for: indexPath) as? FixtureGroupCell else { return nil }
        cell.configureView(with: fixtureGroup)
        if !fixtureGroup.fixtures.isEmpty {
          cell.tapAction = { [weak self] in
            guard let self else { return }
            cell.state = fixtureGroup.isExpanded ? .collapsed : .expanded
            didToggleFixtures.accept(fixtureGroup)
          }
        } else {
          cell.state = .nonExpandable
        }
        return cell
      case .fixture(let fixture):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FixtureCell.identifier, for: indexPath) as? FixtureCell else { return nil }
        cell.configureView(with: fixture)
        return cell
      case .dummy:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FixtureDummyCell.identifier, for: indexPath) as? FixtureDummyCell else { return nil }
        return cell
      }
    }
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setBackgroundColor(with: .subBackground)
    setConstraints()
    setIndicator()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
    setViewModel()
  }
  
  private func setViewModel() {
    let viewDidLoad = PublishSubject<Date>()
    let input = MatchesViewModel.Input(viewDidLoad: viewDidLoad, didToggleFixtures: didToggleFixtures)
    let output = viewModel.transform(input)
    showIndicator()
    
    output.fixtures
      .subscribe(with: self) { owner, value in
        owner.applySnapshot(for: value)
        owner.hideIndicator()
      }
      .disposed(by: disposeBag)
    
    input.viewDidLoad.onNext(matchesDate.date)
  }
  
  private func setIndicator() {
    view.addSubview(activityIndicator)
    view.bringSubviewToFront(activityIndicator)
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
  
  private func setConstraints() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func applySnapshot(for items: [FixtureGroupByCompetition]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections(Section.allCases)
    
    if !items.isEmpty {
      var fixtureGroupItems: [Item] = []
      items.forEach { item in
        fixtureGroupItems.append(.fixtureGroupByCompetition(item))
        if item.fixtures.isEmpty {
          fixtureGroupItems.append(.dummy(item.info.id))
        } else if item.isExpanded {
          item.fixtures.forEach { fixture in
            fixtureGroupItems.append(.fixture(fixture))
          }
        }
      }
      snapshot.appendItems(fixtureGroupItems, toSection: .followingCompetitions)
    }
    datasource.apply(snapshot, animatingDifferences: true)
  }
  
  private func toggleSnapshot(for group: FixtureGroupByCompetition, at indexPath: IndexPath) {
    var currentSnapshot = datasource.snapshot()
    
    let existingItemsForGroup = currentSnapshot.itemIdentifiers(inSection: .followingCompetitions).filter {
      if case .fixtureGroupByCompetition(let group) = $0 {
        return group.info.id == group.info.id
      }
      return false
    }
    
    if group.isExpanded {
      var newItems: [Item] = []
      for fixture in group.fixtures {
        newItems.append(.fixture(fixture))
      }
      
      for (index, item) in newItems.enumerated() {
        currentSnapshot.insertItems([item], afterItem: currentSnapshot.itemIdentifiers(inSection: .followingCompetitions)[indexPath.row + index])
      }
    } else {
      currentSnapshot.deleteItems(existingItemsForGroup)
    }
    
    datasource.apply(currentSnapshot, animatingDifferences: true)
  }
  
  private func setErrorLabel(_ errorType: MatchesError) {
    errorLabel.numberOfLines = 0
    errorLabel.textAlignment = .center
    
    switch errorType {
    case .nofollowCompetition:
      errorLabel.text = LocalizedStrings.TabBar.Leagues.noFollowCompetition.localizedValue
    case .serverError:
      errorLabel.text = LocalizedStrings.Common.serverErrorContent.localizedValue
    }
    
    view.addSubview(errorLabel)
    errorLabel.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(0.8)
    }
  }
}

extension MatchesTableViewController {
  enum Section: Int, CaseIterable {
    case followingCompetitions
  }
  
  enum Item: Hashable {
    case fixtureGroupByCompetition(FixtureGroupByCompetition)
    case fixture(Fixture)
    case dummy(Int)
  }
}

enum MatchesError {
  case nofollowCompetition
  case serverError
}
