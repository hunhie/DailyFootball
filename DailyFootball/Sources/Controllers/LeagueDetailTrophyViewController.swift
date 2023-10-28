////
////  LeagueDetailTrophyViewController.swift
////  DailyFootball
////
////  Created by walkerhilla on 2023/10/26.
////
//
//import UIKit
//
//final class LeagueDetailTrophyViewController: BaseViewController, InnerScrollProvidable {
//
//  var innerScroll: ScrollGestureRestrictable = {
//    let view = InnerScrollTableView(frame: .zero, style: .grouped)
//    return view
//  }()
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//
//    setupInnerScroll()
//  }
//
//  func setupInnerScroll() {
//    guard let innerScroll = innerScroll as? InnerScrollTableView else { return }
//
//    view.addSubview(innerScroll)
//    innerScroll.snp.makeConstraints { make in
//      make.edges.equalTo(view.safeAreaLayoutGuide)
//    }
//
//    innerScroll.delegate = self
//  }
//}
//
//extension LeagueDetailTrophyViewController {
//  enum Section {
//    case trophy
//  }
//
//  enum Item: Hashable {
//    case trophy(Trophy)
//  }
//}
//
//extension LeagueDetailTrophyViewController: UITableViewDelegate {
//
//}
