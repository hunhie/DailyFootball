//
//  MatchesViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/27.
//

import UIKit
import Tabman
import SnapKit
import Pageboy

final class MatchesViewController: TabmanViewController {
  
  let viewControllers: [UIViewController] = [
    MatchesTableViewController(),
    MatchesTableViewController(),
    MatchesTableViewController()
  ]
  
  let viewModel: MatchesViewModel = MatchesViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigation()
    configureTabmanView(at: .top)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
  }
  
  func setupNavigation() {
    self.navigationItem.title = LocalizedStrings.TabBar.Matches.title.localizedValue
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController?.navigationBar.backgroundColor = UIColor.appColor(for: .background)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    navigationBarAppearance.backgroundColor = UIColor.appColor(for: .background)
    navigationItem.scrollEdgeAppearance = navigationBarAppearance
    navigationItem.standardAppearance = navigationBarAppearance
  }
  
  func configureTabmanView(at position: TabmanViewController.BarLocation = .top) {
    self.dataSource = self
    
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
      button.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
      button.contentInset = .init(top: 12, left: 0, bottom: 3, right: 0)
      button.selectedTintColor = .label
      button.tintColor = .label
    }

    addBar(bar, dataSource: self, at: position)
  }
}

extension MatchesViewController: PageboyViewControllerDataSource, TMBarDataSource {
  func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
    return viewControllers.count
  }
  
  func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
    return viewControllers[safe: index]
  }
  
  func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
    return .at(index: 1)
  }
  
  func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
    let title = LocalizedStrings.Matches.MatchesTab.allCases[safe: index]?.localizedValue ?? ""
    return TMBarItem(title: title)
  }
}
