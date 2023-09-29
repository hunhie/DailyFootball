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
    
    configureTabBar()
  }
  
  func configureTabBar() {
    view.backgroundColor = .systemBackground
    
    tabBar.barTintColor = .white
    tabBar.isTranslucent = false
    tabBar.tintColor = .label
    tabBar.unselectedItemTintColor = .gray
    
    
    let league = UINavigationController(rootViewController: LeaguesViewController())
    league.tabBarItem.image = UIImage(systemName: "trophy.fill")
    league.tabBarItem.title = LocalizedStrings.TabBar.Leagues.title.localizedValue
    let matches = UINavigationController(rootViewController: MatchesViewController())
    matches.tabBarItem.image = UIImage(systemName: "sportscourt.fill")
    matches.tabBarItem.title = LocalizedStrings.TabBar.Matches.title.localizedValue
    let following = UINavigationController(rootViewController: FollowingViewController())
    following.tabBarItem.image = UIImage(systemName: "star.fill")
    following.tabBarItem.title = LocalizedStrings.TabBar.Following.title.localizedValue
    let news = UINavigationController(rootViewController: NewsViewController())
    news.tabBarItem.image = UIImage(systemName: "newspaper.fill")
    news.tabBarItem.title = LocalizedStrings.TabBar.News.title.localizedValue
    
    viewControllers = [league, matches, following, news]
  }
}
