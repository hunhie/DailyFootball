//
//  CustomTabmanViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/22.
//

import UIKit
import Tabman
import Pageboy

protocol TabmanViewConfigurable: AnyObject {
  var viewControllers: [InnerScrollProvidable] { get }
  func setupTabmanBar() -> Tabman.TMBarView<Tabman.TMHorizontalBarLayout, Tabman.TMLabelBarButton, Tabman.TMLineBarIndicator>
  func setupTabmanBarItem (at index: Int) -> TMBarItemable
}

protocol CustomTabmanViewControllerDelegate: AnyObject {
  func tabmanViewController(_ controller: CustomTabmanViewController, didUpdateInnerScrollView scrollView: ScrollGestureRestrictable?)
}

class CustomTabmanViewController: TabmanViewController {
  
  weak var delegate: CustomTabmanViewControllerDelegate?
  weak var configurable: TabmanViewConfigurable?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNotificationCenter()
    configureTabmanView(at: .top)
    delegate?.tabmanViewController(self, didUpdateInnerScrollView: currentInnerScrollView)
  }
  
  private func setNotificationCenter() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleOuterScrollVisibleNotification), name: Notification.Name("OuterScrollDidBecomeVisible"), object: nil)
  }
  
  @objc private func handleOuterScrollVisibleNotification() {
    resetOtherScrollPositions()
  }
  
  private func resetOtherScrollPositions() {
    otherInnerScrollViews.forEach { scrollableView in
      scrollableView?.contentOffset = .zero
    }
  }
  
  override func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: TabmanViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
    delegate?.tabmanViewController(self, didUpdateInnerScrollView: currentInnerScrollView)
  }
}

extension CustomTabmanViewController {
  var currentInnerScrollView: ScrollGestureRestrictable? {
    if let currentIndex = self.currentIndex {
      let viewControllers = configurable?.viewControllers ?? []
      let viewController = viewControllers[currentIndex]
      return viewController.innerScroll
    }
    return nil
  }
  
  var otherInnerScrollViews: [ScrollGestureRestrictable?] {
    let viewControllers = configurable?.viewControllers ?? []
    return viewControllers.enumerated().compactMap { index, viewController in
      if index != self.currentIndex {
        let vc = viewController
        return vc.innerScroll
      }
      return nil
    }
  }
  
  func configureTabmanView(at position: TabmanViewController.BarLocation = .top) {
    self.dataSource = self
    
    if let configurable {
      let bar = configurable.setupTabmanBar()
      addBar(bar, dataSource: self, at: position)
    }
  }
}

extension CustomTabmanViewController: PageboyViewControllerDataSource, TMBarDataSource {
  func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
    let viewControllers = configurable?.viewControllers ?? []
    return viewControllers.count
  }
  
  func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
    let viewControllers = configurable?.viewControllers ?? []
    return viewControllers[safe: index] as? UIViewController
  }
  
  func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
    return nil
  }
  
  func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
    return configurable?.setupTabmanBarItem(at: index) ?? TMBarItem(title: "탭 \(index)")
  }
}
