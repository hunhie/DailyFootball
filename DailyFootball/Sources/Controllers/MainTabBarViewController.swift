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
    tabBar.barTintColor = UIColor.systemBackground
    tabBar.tintColor = .black
    tabBar.unselectedItemTintColor = .gray
    
    let league = UINavigationController(rootViewController: LeagueViewController())
    league.tabBarItem.image = UIImage(systemName: "trophy.fill")
    league.tabBarItem.title = "리그"
    let matchup = UINavigationController(rootViewController: MatchupViewController())
    matchup.tabBarItem.image = UIImage(systemName: "sportscourt.fill")
    matchup.tabBarItem.title = "경기"
    let following = UINavigationController(rootViewController: FollowingViewController())
    following.tabBarItem.image = UIImage(systemName: "star.fill")
    following.tabBarItem.title = "팔로잉"
    let news = UINavigationController(rootViewController: NewsViewController())
    news.tabBarItem.image = UIImage(systemName: "newspaper.fill")
    news.tabBarItem.title = "뉴스"
    
    viewControllers = [league, matchup, following, news]
  }
}
