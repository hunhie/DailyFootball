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

class LeaguesViewController: LeaguesBaseViewController, LeaguesBaseViewDelegate, LeaguesSearchResultsDelegate {
  
  private let resultsViewController = LeaguesSearchResultsViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigation()
    setResultsView()
    delegate = self
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
  
  func setResultsView() {
    navigationItem.searchController?.searchBar.rx.text.orEmpty.changed
      .subscribe(with: self, onNext: { owner, value in
        owner.resultsViewController.viewModel.searchCompetition(with: value)
      })
      .disposed(by: disposeBag)
  }
  
  func didTapCompetition(vc: UIViewController) {
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func didTapComp(vc: UIViewController) {
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func didScroll() {
    navigationItem.searchController?.searchBar.resignFirstResponder()
  }
  
  func didscroll() {
    navigationItem.searchController?.searchBar.resignFirstResponder()
  }
}
