//
//  LeagueDetailViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/20.
//

import UIKit

final class LeagueDetailViewController: DynamicHeaderTabManViewController {
  
  private lazy var followButton: UIBarButtonItem = {
    let title = competition.isFollowed ? LocalizedStrings.TabBar.Leagues.followingButton.localizedValue : LocalizedStrings.TabBar.Leagues.followButton.localizedValue
    let view = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(followButtonTapped))
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold),
    ]
    
    view.setTitleTextAttributes(attributes, for: .normal)
    view.setTitleTextAttributes(attributes, for: .selected)
    
    return view
  }()
  
  private let viewModel: LeaguesViewModel
  
  var competition: Competition {
    didSet {
      setFollowButtonColor()
    }
  }
  
  init(competition: Competition, viewModel: LeaguesViewModel, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
    self.competition = competition
    self.viewModel = viewModel
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setFollowButtonColor()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
  }
  
  func setupNavigationBar() {
    let navigationAppearance = UINavigationBarAppearance()
    navigationAppearance.configureWithTransparentBackground()
    navigationAppearance.backgroundColor = UIColor.appColor(for: .background)
    navigationAppearance.shadowImage = UIImage()
    
    navigationController?.navigationBar.standardAppearance = navigationAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = competition.country.name
    
    navigationItem.rightBarButtonItem = followButton
  }
  
  @objc func followButtonTapped() {
    if competition.isFollowed {
      viewModel.handle(action: .unfollowCompetition(competition))
    } else {
      viewModel.handle(action: .followCompetition(competition))
    }
    competition.isFollowed.toggle()
  }

  private func setFollowButtonColor() {
    if competition.isFollowed {
      followButton.title = LocalizedStrings.TabBar.Leagues.followButton.localizedValue
      followButton.tintColor = UIColor.appColor(for: .subLabel)
    } else {
      followButton.title = LocalizedStrings.TabBar.Leagues.followingButton.localizedValue
      followButton.tintColor = UIColor.appColor(for: .accentColor)
    }
  }
}

extension LeagueDetailViewController: DynamicHeaderTabManViewControllerDelegate {
  func headerView(for viewController: DynamicHeaderTabManViewController) -> DynamicHeaderView {
    LeagueDetailHeaderView(competition: competition)
  }
  
  func tabmanViewController(for viewController: DynamicHeaderTabManViewController) -> CustomTabmanViewController {
    LeagueDetailTabmanViewController(competition: competition)
  }
}


