//
//  LeaguesSearchResultsViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 11/13/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol LeaguesSearchResultsDelegate: AnyObject {
  func didTapComp(vc: UIViewController)
  func didscroll()
}

final class LeaguesSearchResultsViewController: LeaguesBaseViewController, LeaguesBaseViewDelegate {
  
  func didScroll() {
    resultsDelegate?.didscroll()
  }
  
  weak var resultsDelegate: LeaguesSearchResultsDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupNavigation()
    setViewModel()
    delegate = self
  }
  
  func setupNavigation() {
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
  
  func setViewModel() {
    let viewDidLoad = PublishSubject<Void>()
    let input = LeaguesViewModel.Input(viewDidLoad: viewDidLoad, didToggleCompeitionGroup: didToggleCompeitionGroup, didToggleEditMode: didToggleEditMode, reorderEvent: reorderEvent)
    let output = viewModel.transform(input)
    
    leagueView.showIndicator()
    
    output.competitionGroups
      .subscribe(with: self) { owner, value in
        let searchText = owner.viewModel.searchKeyword.value.lowercased()
        let filteredCompetitionGroups = value.data
          .map { group -> CompetitionGroupByCountry in
            var modifiedGroup = group
            modifiedGroup.isExpanded = true
            
            if group.country.name.lowercased().contains(searchText) {
              return modifiedGroup
            } else {
              let filteredCompetitions = group.competitions.filter {
                $0.info.name.lowercased().contains(searchText)
              }
              
              modifiedGroup.competitions = filteredCompetitions
              return modifiedGroup
            }
          }
          .filter { !$0.competitions.isEmpty || $0.country.name.lowercased().contains(searchText) }
        
        owner.leagueView.updateAllCompetitions(with: filteredCompetitionGroups, animated: value.animated)
        owner.leagueView.hideIndicator()
      } onError: { owner, error in
        dump(error)
      }
      .disposed(by: disposeBag)

    
    output.followedCompetitions
      .subscribe(with: self) { owner, value in
        let searchText = owner.viewModel.searchKeyword.value.lowercased()
        let filteredFollowedCompetitions = value.data
          .filter {
            let title = $0.info.name.lowercased()
            let country = $0.country.name.lowercased()
            return title.contains(searchText) || country.contains(searchText)
          }
        
        owner.leagueView.updateFollowingCompetitions(with: filteredFollowedCompetitions, animated: value.animated)
      }
      .disposed(by: disposeBag)
    
    output.isEditingMode
      .bind(with: self) { owner, value in
        owner.leagueView.toggleEditingModeForFollowingCompetitionSection(value)
      }
      .disposed(by: disposeBag)
    
    input.viewDidLoad.onNext(())
  }
  
  func didTapCompetition(vc: UIViewController) {
    resultsDelegate?.didTapComp(vc: vc)
  }
}
