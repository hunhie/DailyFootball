//
//  LeagueDetailTabmanViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/23.
//

import UIKit
import Tabman

final class LeagueDetailTabmanViewController: CustomTabmanViewController {
  
  lazy var tabs: [InnerScrollProvidable] = [
    LeagueDetailStandingsViewController(competition: competition),
    LeagueDetailScorersViewController(competition: competition)
  ]
  
  let competition: Competition
  
  init(competition: Competition) {
    self.competition = competition
    super.init(nibName: nil, bundle: nil)
    
    configurable = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.appColor(for: .subBackground)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
  }
}

extension LeagueDetailTabmanViewController: TabmanViewConfigurable {
  var viewControllers: [InnerScrollProvidable] {
    return tabs
  }
  
  func setupTabmanBarItem(at index: Int) -> Tabman.TMBarItemable {
    let title = LocalizedStrings.Leagues.LeagueDetailTab.allCases[safe: index]?.localizedValue ?? "\(index)"
    return TMBarItem(title: title)
  }
  
  func setupTabmanBar() -> TMBarView<TMHorizontalBarLayout, TMLabelBarButton, TMLineBarIndicator> {
    let bar = TMBar.ButtonBar()
    
    bar.backgroundView.style = .flat(color: UIColor.appColor(for: .background))
    
    bar.indicator.cornerStyle = .eliptical
    bar.indicator.tintColor = UIColor.appColor(for: .accentDarkAndBlack)
    bar.indicator.weight = .light
    
    bar.spacing = 0
    
    bar.layout.contentInset = .init(top: 0, left: 20, bottom: 1, right: 20)
    bar.layout.interButtonSpacing = 25
    bar.layout.alignment = .leading
    bar.layout.transitionStyle = .snap
    bar.layout.separatorWidth = 10
    
    bar.buttons.customize { (button) in
      button.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
      button.contentInset = .init(top: 12, left: 0, bottom: 3, right: 0)
      button.selectedTintColor = .label
      button.tintColor = .label
    }
    
    return bar
  }
}
