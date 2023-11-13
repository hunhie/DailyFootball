//
//  LeaguesView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import SnapKit

final class LeaguesView: UIView {
  
  lazy var tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .grouped)
    view.separatorStyle = .none
    view.rowHeight = 60
    view.dragInteractionEnabled = true
    view.backgroundColor = UIColor.appColor(for: .subBackground)
    return view
  }()
  
  lazy var activityIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    return view
  }()
  
  private typealias DataSource = UITableViewDiffableDataSource<Section, Item>
  
  private var dataSource: DataSource?
  
  weak var delegate: LeaguesViewDelegate?
  
  var activeSections: Set<Section> = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureView()
    setConstraints()
    initializeSections()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureView() {
    tableView.register(CompetitionGroupCell.self, forCellReuseIdentifier: CompetitionGroupCell.identifier)
    tableView.register(CompetitionCell.self, forCellReuseIdentifier: CompetitionCell.identifier)
    tableView.register(FollowingCompetitionCell.self, forCellReuseIdentifier: FollowingCompetitionCell.identifier)
    tableView.register(LeaguesTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: LeaguesTableViewHeaderView.identifier)
    
    setDataSource()
  }
  
  private func setConstraints() {
    addSubview(tableView)
    tableView.addSubview(activityIndicator)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    activityIndicator.snp.makeConstraints { make in
      make.centerX.equalTo(tableView)
      make.centerY.equalTo(tableView).multipliedBy(0.6)
    }
  }
  
  func showIndicator() {
    activityIndicator.startAnimating()
  }
  
  func hideIndicator() {
    activityIndicator.stopAnimating()
  }
}

//MARK: - Data & State Management
extension LeaguesView {
  func updateFollowingCompetitions(with competitions: [Competition], animated: Bool) {
    updateFollowedCompetitionsSnapshot(competitions, animated: animated)
  }
  
  func updateAllCompetitions(with groups: [CompetitionGroupByCountry], animated: Bool) {
    updateAllCompetitionsSnapshot(groups, animated: animated)
  }
  
//  func followCompetition(with competition: Competition, animated: Bool) {
//    addFollowedCompetition(competition, animated: animated)
//  }
//  
//  func unfollowCompetition(with competition: Competition, animated: Bool) {
//    removeFollowedCompetition(competition, animated: animated)
//  }
//  
//  func reorderFollowingCompetitions(from: IndexPath, to: IndexPath) {
//    moveFollowedCompetition(from: from, to: to)
//  }
  
  func competition(at indexPath: IndexPath) -> Competition? {
    if let item = dataSource?.itemIdentifier(for: indexPath), case .competition(let sectionedCompetition, _) = item {
      return sectionedCompetition.competition
    }
    return nil
  }
}

//MARK: - TableView Edit Mode
extension LeaguesView {
  func shouldAllowDrag(at indexPath: IndexPath) -> Bool {
    guard let dataSource,
          let section = dataSource.sectionIdentifier(for: indexPath.section) else { return false }
    return section == .followingCompetition
  }
  
  func toggleEditingModeForFollowingCompetitionSection(_ isEdit: Bool) {
    reloadSection(.followingCompetition)
  }
  
  private func synchronizaAllCompetitionsForUnFollowed(_ competition: Competition) {
    guard let dataSource else { return }
    let targetItem = Item.competition(SectionedCompetition(competition: competition, sectionIdentifier: .allCompetition))
    if let targetIndexPath = dataSource.indexPath(for: targetItem),
       let targetCell = tableView.cellForRow(at: targetIndexPath) as? CompetitionCell {
      var competition = competition
      competition.isFollowed.toggle()
      targetCell.competition = competition
    }
  }
}

//MARK: - Tableview Datasource
extension LeaguesView {
  enum Section: CaseIterable {
    case followingCompetition
    case allCompetition
  }
  
  enum Item: Hashable {
    case followingCompetition(SectionedCompetition)
    case competition(SectionedCompetition, isLast: Bool = false)
    case competitionGroup(CompetitionGroupByCountry)
  }
  
  struct SectionedCompetition: Hashable {
    var competition: Competition
    let sectionIdentifier: Section
    
    static func == (lhs: SectionedCompetition, rhs: SectionedCompetition) -> Bool {
      return lhs.competition.id == rhs.competition.id &&
      lhs.sectionIdentifier == rhs.sectionIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(competition.id)
      hasher.combine(sectionIdentifier)
    }
  }
  
  private func setDataSource() {
    dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
      guard let self else { return nil }
      
      switch item {
      case .followingCompetition(let sectionedCompetition):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowingCompetitionCell.identifier, for: indexPath) as? FollowingCompetitionCell else { return nil }
        cell.configureView(with: sectionedCompetition.competition)
        cell.deleteAction = { [weak self] in
          guard let self else { return }
          self.delegate?.didUnfollow(competition: sectionedCompetition.competition)
          self.synchronizaAllCompetitionsForUnFollowed(sectionedCompetition.competition)
        }
        cell.tapAction = { [weak self] in
          guard let self else { return }
          self.delegate?.didTapCompetition(competition: sectionedCompetition.competition)
        }
        
        if let isEdit = delegate?.isEditMode() {
          cell.isEditingMode = isEdit
        }
      
        return cell
        
      case .competition(let sectionedCompetition, _):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompetitionCell.identifier, for: indexPath) as? CompetitionCell else { return nil }
        let competition = sectionedCompetition.competition
        cell.configureView(with: competition)
        cell.followAction = { [weak self] item in
          guard let self else { return }
          if item.isFollowed {
            self.delegate?.didUnfollow(competition: competition)
            cell.competition?.isFollowed = false
          } else {
            self.delegate?.didFollow(competition: competition)
            cell.competition?.isFollowed = true
          }
        }
        cell.tapAction = { [weak self] item in
          guard let self else { return }
          self.delegate?.didTapCompetition(competition: item)
        }
        
        return cell
        
      case .competitionGroup(let competitionGroup):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompetitionGroupCell.identifier, for: indexPath) as? CompetitionGroupCell else { return nil }
        cell.configureView(with: competitionGroup)
        cell.tapAction = { [weak self] in
          guard let self else { return }
          self.delegate?.didTapCompetitionGroup(competitionGroup: competitionGroup)
        }
        return cell
      }
    }
  }
  
  private func initializeSections() {
    guard let dataSource = self.dataSource else { return }
    
    var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    initialSnapshot.appendSections([.followingCompetition, .allCompetition])
    
    dataSource.apply(initialSnapshot, animatingDifferences: false)
  }
  
  private func updateFollowedCompetitionsSnapshot(_ competitions: [Competition], animated: Bool) {
    guard let dataSource = self.dataSource else { return }
    dataSource.defaultRowAnimation = .none
    
    var currentSnapshot = dataSource.snapshot()
    currentSnapshot.deleteItems(currentSnapshot.itemIdentifiers(inSection: .followingCompetition))
    
    if !competitions.isEmpty {
      currentSnapshot.appendItems(competitions.map { .followingCompetition(SectionedCompetition(competition: $0, sectionIdentifier: .followingCompetition)) }, toSection: .followingCompetition)
      activeSections.insert(.followingCompetition)
    } else {
      activeSections.remove(.followingCompetition)
    }
    
    dataSource.apply(currentSnapshot, animatingDifferences: animated)
  }
  
  private func updateAllCompetitionsSnapshot(_ competitionGroups: [CompetitionGroupByCountry], animated: Bool) {
    guard let dataSource = self.dataSource else { return }
    dataSource.defaultRowAnimation = .none
    var currentSnapshot = dataSource.snapshot()
    currentSnapshot.deleteItems(currentSnapshot.itemIdentifiers(inSection: .allCompetition))
    
    if !competitionGroups.isEmpty {
      var allCompetitionItems: [Item] = []
      
      for competitionGroup in competitionGroups {
        if competitionGroup.isExpanded {
          allCompetitionItems.append(.competitionGroup(competitionGroup))
          for (index, competition) in competitionGroup.competitions.enumerated() {
            let isLast = index == competitionGroup.competitions.count - 1
            allCompetitionItems.append(.competition(SectionedCompetition(competition: competition, sectionIdentifier: .allCompetition), isLast: isLast))
          }
        } else {
          allCompetitionItems.append(.competitionGroup(competitionGroup))
        }
      }
      
      currentSnapshot.appendItems(allCompetitionItems, toSection: .allCompetition)
      activeSections.insert(.allCompetition)
    } else {
      activeSections.remove(.allCompetition)
    }
    
    dataSource.apply(currentSnapshot, animatingDifferences: animated)
  }
  
  private func reloadSection(_ sectionIdentifier: Section) {
    guard let dataSource else { return }
    
    var currentSnapshot = dataSource.snapshot()
    let itemsInSection = currentSnapshot.itemIdentifiers(inSection: sectionIdentifier)
    currentSnapshot.reloadItems(itemsInSection)
    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }
  
//  private func addFollowedCompetition(_ competition: Competition, animated: Bool) {
//    guard let dataSource = self.dataSource else { return }
//    dataSource.defaultRowAnimation = .top
//    
//    var currentSnapshot = dataSource.snapshot()
//    currentSnapshot.appendItems([.followingCompetition(SectionedCompetition(competition: competition, sectionIdentifier: .followingCompetition))], toSection: .followingCompetition)
//    
//    activeSections.insert(.followingCompetition)
//    dataSource.apply(currentSnapshot, animatingDifferences: animated)
//  }
//  
//  private func removeFollowedCompetition(_ competition: Competition, animated: Bool) {
//    guard let dataSource else { return }
//    dataSource.defaultRowAnimation = .bottom
//    
//    var currentSnapshot = dataSource.snapshot()
//    currentSnapshot.deleteItems([.followingCompetition(SectionedCompetition(competition: competition, sectionIdentifier: .followingCompetition))])
//    
//    if currentSnapshot.numberOfItems(inSection: .followingCompetition) == 0 {
//      activeSections.remove(.followingCompetition)
//    }
//    
//    dataSource.apply(currentSnapshot, animatingDifferences: true)
//  }
//  
//  private func moveFollowedCompetition(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//    guard let dataSource,
//          let itemToMove = dataSource.itemIdentifier(for: sourceIndexPath),
//          let referenceItem = dataSource.itemIdentifier(for: destinationIndexPath) else { return }
//    
//    var currentSnapshot = dataSource.snapshot()
//    if sourceIndexPath > destinationIndexPath {
//      currentSnapshot.moveItem(itemToMove, beforeItem: referenceItem)
//    } else {
//      currentSnapshot.moveItem(itemToMove, afterItem: referenceItem)
//    }
//    
//    dataSource.applySnapshotUsingReloadData(currentSnapshot)
//  }
}
