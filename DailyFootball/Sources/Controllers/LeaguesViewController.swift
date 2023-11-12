//
//  LeaguesViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class LeaguesViewController: BaseViewController {
  
  private let leagueView = LeaguesView()
  private let viewModel = LeaguesViewModel()
  private let disposeBag = DisposeBag()
  private let followEvent = PublishRelay<Competition>()
  private let unfollowEvent = PublishRelay<Competition>()
  private let didToggleCompeitionGroup = PublishRelay<CompetitionGroupByCountry>()
  private let didToggleEditMode = PublishRelay<Void>()
  private let reorderEvent = PublishRelay<(from: IndexPath, to: IndexPath)>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setConstraints()
    setLeagueView()
    setupNavigation()
    setViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
  }
  
  func setLeagueView() {
    leagueView.delegate = self
    leagueView.tableView.delegate = self
    leagueView.tableView.dropDelegate = self
    leagueView.tableView.dragDelegate = self
  }
  
  func setViewModel() {
    let viewDidLoad = PublishSubject<Void>()
    let input = LeaguesViewModel.Input(viewDidLoad: viewDidLoad, followEvent: followEvent, unfollowEvent: unfollowEvent, didToggleCompeitionGroup: didToggleCompeitionGroup, didToggleEditMode: didToggleEditMode, reorderEvent: reorderEvent)
    
    let output = viewModel.transform(input)
    leagueView.showIndicator()
    
    output.competitionGroups
      .subscribe(with: self) { owner, value in
        owner.leagueView.updateAllCompetitions(with: value, animated: true)
        owner.leagueView.hideIndicator()
      } onError: { owner, error in
        dump(error)
      }
      .disposed(by: disposeBag)

    
    output.followedCompetitions
      .subscribe(with: self) { owner, value in
        owner.leagueView.updateFollowingCompetitions(with: value, animated: true)
      }
      .disposed(by: disposeBag)
    
    output.isEditingMode
      .bind(with: self) { owner, value in
        owner.leagueView.toggleEditingModeForFollowingCompetitionSection(value)
      }
      .disposed(by: disposeBag)
    
    input.viewDidLoad.onNext(())
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
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationBar.backgroundColor = UIColor.appColor(for: .background)
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.backgroundColor = UIColor.appColor(for: .background)
    
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
//    viewModel.handleSearchInput(isActive: searchController.isActive, searchText: searchController.searchBar.text)
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
          let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeaguesTableViewHeaderView.identifier) as? LeaguesTableViewHeaderView else { return nil }
    
    headerView.delegate = self
    
    switch currentSection {
    case .followingCompetition:
      headerView.showEditButton(true)
      headerView.setHeaderTitle(title: LocalizedStrings.TabBar.Leagues.sectionFavorite.localizedValue)
    case .allCompetition:
      headerView.showEditButton(false)
      headerView.setHeaderTitle(title: LocalizedStrings.TabBar.Leagues.sectionAllCompetition.localizedValue)
    }
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let isHeaderHidden: Bool
    
    if let currentSection = LeaguesView.Section.allCases[safe: section],
       leagueView.activeSections.contains(currentSection) {
      isHeaderHidden = false
    } else {
      isHeaderHidden = true
    }

    return isHeaderHidden ? 0 : 50
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0 }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
}

extension LeaguesViewController: TableViewEditableDelegate {
  func isEditMode() -> Bool {
    return viewModel.isEditMode.value
  }
  
  func didTapEditButton() {
    didToggleEditMode.accept(())
  }
}

extension LeaguesViewController: LeaguesViewDelegate {
  func didFollow(competition: Competition) {
    followEvent.accept(competition)
  }
  
  func didUnfollow(competition: Competition) {
    unfollowEvent.accept(competition)
  }
  
  func didTapCompetitionGroup(competitionGroup: CompetitionGroupByCountry) {
    didToggleCompeitionGroup.accept(competitionGroup)
  }
  
  func didTapCompetition(competition: Competition) {
    let vc = LeagueDetailViewController(competition: competition, viewModel: viewModel)
    navigationController?.pushViewController(vc, animated: true)
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
          let destinationIndexPath = coordinator.destinationIndexPath,
          sourceIndexPath != destinationIndexPath else { return }
    
    reorderEvent.accept((from: sourceIndexPath, to: destinationIndexPath))
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
