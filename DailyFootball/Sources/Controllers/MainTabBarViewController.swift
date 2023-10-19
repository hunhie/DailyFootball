//
//  MainTabBarViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    configureTabBar()
  }
  
  func configureTabBar() {
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .systemBackground
    
    tabBar.tintColor = .label
    tabBar.unselectedItemTintColor = .gray
    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
    
    let league = UINavigationController(rootViewController: LeaguesViewController())
    league.tabBarItem.image = UIImage(systemName: "trophy.fill")
    league.tabBarItem.title = LocalizedStrings.TabBar.Leagues.title.localizedValue
    
    let matches = UINavigationController(rootViewController: MatchesViewController())
    matches.tabBarItem.image = UIImage(systemName: "sportscourt.fill")
    matches.tabBarItem.title = LocalizedStrings.TabBar.Matches.title.localizedValue
    
    let news = UINavigationController(rootViewController: NewsViewController())
    news.tabBarItem.image = UIImage(systemName: "newspaper.fill")
    news.tabBarItem.title = LocalizedStrings.TabBar.News.title.localizedValue
    
    let more = UINavigationController(rootViewController: MoreViewController())
    more.tabBarItem.image = UIImage(named: "more.fill")
    more.tabBarItem.title = LocalizedStrings.TabBar.More.title.localizedValue
    
    viewControllers = [league, matches, news, more]
  }
}
