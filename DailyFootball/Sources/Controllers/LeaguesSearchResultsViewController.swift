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
  
  func didTapCompetition(vc: UIViewController) {
    resultsDelegate?.didTapComp(vc: vc)
  }
}
