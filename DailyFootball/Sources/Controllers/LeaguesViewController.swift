//
//  LeaguesViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import SnapKit

final class LeaguesViewController: BaseViewController {
  
  let leagueView = LeagueView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigation()
  }
  
  override func loadView() {
    view = leagueView
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
}

extension LeaguesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
//    dump(searchController.searchBar.text)
  }
}
