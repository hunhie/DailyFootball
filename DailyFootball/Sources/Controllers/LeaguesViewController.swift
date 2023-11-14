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

class LeaguesViewController: LeaguesBaseViewController, LeaguesSearchResultsDelegate, LeaguesBaseViewDelegate {
  private lazy var resultsViewController = LeaguesSearchResultsViewController(viewModel: viewModel)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    setupNavigation()
    setViewModel()
    setResultsView()
    resultsViewController.resultsDelegate = self
  }
  
  func setupNavigation() {
    let searchController = UISearchController(searchResultsController: resultsViewController)
    searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchController.searchBar.placeholder = LocalizedStrings.TabBar.Leagues.searchbarPlaceholder.localizedValue
    
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
  
  func setViewModel() {
    let viewDidLoad = PublishSubject<Void>()
    let input = LeaguesViewModel.Input(viewDidLoad: viewDidLoad, didToggleCompeitionGroup: didToggleCompeitionGroup, didToggleEditMode: didToggleEditMode, reorderEvent: reorderEvent)
    let output = viewModel.transform(input)
    
    leagueView.showIndicator()
    
    output.competitionGroups
      .subscribe(with: self) { owner, value in
        owner.leagueView.updateAllCompetitions(with: value.data, animated: value.animated)
        owner.leagueView.hideIndicator()
      } onError: { owner, error in
        dump(error)
      }
      .disposed(by: disposeBag)

    
    output.followedCompetitions
      .subscribe(with: self) { owner, value in
        owner.leagueView.updateFollowingCompetitions(with: value.data, animated: value.animated)
      }
      .disposed(by: disposeBag)
    
    output.isEditingMode
      .bind(with: self) { owner, value in
        owner.leagueView.toggleEditingModeForFollowingCompetitionSection(value)
      }
      .disposed(by: disposeBag)
    
    input.viewDidLoad.onNext(())
  }
  
  func setResultsView() {
    guard let searchController = navigationItem.searchController else { return }
    searchController.searchBar.rx.text.orEmpty.changed
      .subscribe(with: self, onNext: { owner, value in
        owner.viewModel.searchKeyword.accept(value)
      })
      .disposed(by: disposeBag)
    
    
    let searchText = searchController.searchBar.rx.text.orEmpty.map { $0.isEmpty }
    let searchCancel = searchController.searchBar.rx.cancelButtonClicked.map { true }.asObservable()
    
    searchText
      .subscribe(with: self) { owner, isEmpty in
        if isEmpty {
          owner.resultsViewController.viewModel.dataRestore()
        }
      }
      .disposed(by: disposeBag)
    
    searchCancel
      .subscribe(with: self) { owner, isEmpty in
        if isEmpty {
          owner.resultsViewController.viewModel.dataRestore()
        }
      }
      .disposed(by: disposeBag)
  }
  
  func didTapCompetition(vc: UIViewController) {
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func didTapComp(vc: UIViewController) {
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func didscroll() {
    navigationItem.searchController?.searchBar.resignFirstResponder()
  }
}
