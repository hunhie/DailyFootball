//
//  LeaguesViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import SnapKit

final class LeaguesViewController: BaseViewController {
  
  private let leagueView = LeaguesView()
  private var viewModel = LeaguesViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setConstraints()
    setLeagueView()
    setupNavigation()
    setViewModel()
    
    viewModel.handle(action: .fetchFollowedCompetitions)
    viewModel.handle(action: .fetchCompetitionGroups)
  }
  
  func setLeagueView() {
    leagueView.delegate = self
    leagueView.tableView.delegate = self
    leagueView.tableView.dropDelegate = self
    leagueView.tableView.dragDelegate = self
  }
  
  func setViewModel() {
    viewModel.state.bind { [weak self] state in
      guard let self else { return }
      switch state {
      case .error(let error):
        print(error)
      case .loading:
        return
      case .competitionsLoaded(let response):
        leagueView.updateAllCompetitions(with: response, animated: false)
      case .followedCompetitionsLoad(let response, let animated):
        leagueView.updateFollowingCompetitions(with: response, animated: animated)
      case .followedSuccess(let response):
        leagueView.followCompetition(with: response, animated: true)
      case .unfollowedSuccess(let response):
        leagueView.unfollowCompetition(with: response, animated: true)
      case .competitionGroupExpansionToggled(let response):
        leagueView.updateAllCompetitions(with: response, animated: true)
      case .searchResultLoaded(filteredCompetitionGroups: let filteredCompetitionGroups, filteredFollowedCompetitions: let filteredFollowedCompetitions):
        leagueView.updateAllCompetitions(with: filteredCompetitionGroups, animated: false)
        leagueView.updateFollowingCompetitions(with: filteredFollowedCompetitions, animated: false)
      case .reorderedFollowedCompetitions(let sourceIndexPath, let destinationIndexPath):
        leagueView.reorderFollowingCompetitions(from: sourceIndexPath, to: destinationIndexPath)
      case .idle:
        return
      }
    }
  }
  
  func setupNavigation() {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchController.searchBar.placeholder = LocalizedStrings.TabBar.Leagues.searchbarPlaceholder.localizedValue
    searchController.searchResultsUpdater = self
    
    self.navigationItem.searchController = searchController
    self.navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    self.navigationItem.hidesSearchBarWhenScrolling = false
    self.navigationItem.title = LocalizedStrings.TabBar.Leagues.title.localizedValue
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationBar.backgroundColor = .white
    
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.backgroundColor = .systemBackground
    
    navigationItem.scrollEdgeAppearance = navigationBarAppearance
    navigationItem.standardAppearance = navigationBarAppearance
    navigationItem.compactAppearance = navigationBarAppearance
  }
  
  func setConstraints() {
    view.addSubview(leagueView)
    leagueView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

extension LeaguesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    viewModel.handleSearchInput(isActive: searchController.isActive, searchText: searchController.searchBar.text)
  }
}

extension LeaguesViewController: UITableViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if let searchController = navigationItem.searchController, searchController.isActive {
      searchController.searchBar.resignFirstResponder()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? CompetitionGroupCell else { return }
    cell.tapAction?()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let currentSection = LeaguesView.Section.allCases[safe: section],
          let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeaguesTableViewHeaderView.identifier) as? LeaguesTableViewHeaderView,
          let headerHeight = tableView.delegate?.tableView?(tableView, heightForHeaderInSection: section),
          headerHeight > 1 else { return nil }
    
    headerView.delegate = self
    
    switch currentSection {
    case .followingCompetition:
      headerView.showEditButton(true)
      headerView.setHeaderTitle(title: "즐겨찾기")
    case .allCompetition:
      headerView.showEditButton(false)
      headerView.setHeaderTitle(title: "모든 리그")
    }
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let isHeaderHidden: Bool
    
    if let currentSection = LeaguesView.Section.allCases[safe: section], leagueView.activeSections.contains(currentSection) {
      isHeaderHidden = false
    } else {
      isHeaderHidden = true
    }
    
    if let headerView = tableView.headerView(forSection: section) as? LeaguesTableViewHeaderView {
      headerView.setVisibility(isHidden: isHeaderHidden)
    }
    
    return isHeaderHidden ? 0.1 : 50
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0 }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
}

extension LeaguesViewController: TableViewEditableDelegate {
  func didTapEditButton(_ isEdit: Bool) {
    leagueView.toggleEditingModeForFollowingCompetitionSection(isEdit)
  }
}

extension LeaguesViewController: LeaguesViewDelegate {
  func didFollow(competition: Competition) {
    viewModel.handle(action: .followCompetition(competition))
  }
  
  func didUnfollow(competition: Competition) {
    viewModel.handle(action: .unfollowCompetition(competition))
  }
  
  func didTapCompetitionGroup(competitionGroup: CompetitionGroup) {
    viewModel.handle(action: .toggleCompetitionGroupDetail(competitionGroup))
  }
}

extension LeaguesViewController: UITableViewDragDelegate {
  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    if leagueView.shouldAllowDrag(at: indexPath),
       let searchController = navigationItem.searchController,
       !searchController.isActive {
      let itemProvider = NSItemProvider()
      let dragItem = UIDragItem(itemProvider: itemProvider)
      dragItem.localObject = indexPath
      return [dragItem]
    } else {
      return []
    }
  }
  
  func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
    let parameters = UIDragPreviewParameters()
    
    if let cell = tableView.cellForRow(at: indexPath) as? FollowingCompetitionCell {
      parameters.backgroundColor = UIColor.clear
      let radius: CGFloat = 16
      let path = UIBezierPath(roundedRect: cell.containerFrame, cornerRadius: radius)
      parameters.visiblePath = path
    }
    
    return parameters
  }
}

extension LeaguesViewController: UITableViewDropDelegate {
  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    guard let sourceIndexPath = coordinator.items.first?.sourceIndexPath,
          let draggableItem = coordinator.items.first?.dragItem,
          let destinationIndexPath = coordinator.destinationIndexPath else { return }
    
    viewModel.handle(action: .reorderCompetition(from: sourceIndexPath, to: destinationIndexPath))
    coordinator.drop(draggableItem, toRowAt: destinationIndexPath)
  }
  
  func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
    let parameters = UIDragPreviewParameters()
    parameters.backgroundColor = .clear
    return parameters
  }
  
  func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    var dropProposal = UITableViewDropProposal(operation: .cancel)
    guard session.items.count == 1 else { return dropProposal }
    guard let destinationIndexPath,
          let section = LeaguesView.Section.allCases[safe: destinationIndexPath.section],
          section == .followingCompetition else { return dropProposal }
    
    dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    
    return dropProposal
  }
}
