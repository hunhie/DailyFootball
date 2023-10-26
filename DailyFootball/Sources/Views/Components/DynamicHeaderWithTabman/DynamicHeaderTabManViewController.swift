//
//  DynamicHeaderTabManViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/22.
//

import UIKit
import Tabman
import SnapKit

protocol DynamicHeaderTabManViewControllerDelegate: AnyObject {
  func headerView(for viewController: DynamicHeaderTabManViewController) -> DynamicHeaderView
  func tabmanViewController(for viewController: DynamicHeaderTabManViewController) -> CustomTabmanViewController
}

class DynamicHeaderTabManViewController: UIViewController {
  
  private lazy var headerView: DynamicHeaderView = {
    return delegate?.headerView(for: self) ?? DynamicHeaderView()
  }()
  
  private lazy var tabmanVC: CustomTabmanViewController = {
    return delegate?.tabmanViewController(for: self) ?? CustomTabmanViewController()
  }()
  
  private lazy var outerScroll: OuterScroll = {
    let view = OuterScroll()
    view.scrollDelegate = self
    return view
  }()
  
  private let tabmanContainerView = UIView()
  
  weak var delegate: DynamicHeaderTabManViewControllerDelegate?
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupComponents()
    setupConstraints()
  }
}

extension DynamicHeaderTabManViewController {
  func setupComponents() {
    tabmanVC.delegate = self
    
    addChild(tabmanVC)
    outerScroll.showsVerticalScrollIndicator = false
    
    view.addSubview(outerScroll)
    outerScroll.addSubview(headerView)
    outerScroll.addSubview(tabmanContainerView)
    tabmanContainerView.addSubview(tabmanVC.view)
    
    tabmanVC.didMove(toParent: self)
  }
  
  func setupConstraints() {
    outerScroll.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    headerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalTo(view)
      make.height.equalTo(headerView.headerHeight)
    }
    
    tabmanContainerView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom)
      make.leading.trailing.equalTo(view)
      make.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    tabmanVC.view.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.horizontalEdges.bottom.equalToSuperview()
    }
  }
}

extension DynamicHeaderTabManViewController: OuterScrollDelegate {
  func ScrollTransitionHeight() -> CGFloat {
    headerView.headerHeight
  }
}

extension DynamicHeaderTabManViewController: CustomTabmanViewControllerDelegate {
  func tabmanViewController(_ controller: CustomTabmanViewController, didUpdateInnerScrollView scrollView: ScrollGestureRestrictable?) {
    outerScroll.innerScrollView = scrollView
  }
}
