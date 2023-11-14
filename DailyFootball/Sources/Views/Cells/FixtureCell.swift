//
//  FixtureCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/29.
//

import UIKit
import Kingfisher
import SnapKit

final class FixtureCell: UITableViewCell {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.appColor(for: .background)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tapGesture)
    return view
  }()
  
  private let matchInfoLabel: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 15, weight: .semibold)
    view.numberOfLines = 1
    view.textAlignment = .center
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return view
  }()
  
  private let homeTeamLogoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFill
    view.tintColor = .black
    return view
  }()
  
  private let awayTeamLogoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFill
    view.tintColor = .black
    return view
  }()
  
  private let homeTeamNameLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
    view.textAlignment = .left
    view.numberOfLines = 1
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return view
  }()
  
  private let awayTeamNameLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
    view.numberOfLines = 1
    view.textAlignment = .right
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var fixture: Fixture?
  
  func configureView(with fixture: Fixture) {
    self.fixture = fixture
    setLogoImage(fixture)
    setTitle(fixture)
    setMatchInfo(fixture)
  }
  
  private func setCellUI() {
    selectionStyle = .none
  }
  
  private func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(matchInfoLabel)
    containerView.addSubview(homeTeamLogoImageView)
    containerView.addSubview(awayTeamLogoImageView)
    containerView.addSubview(homeTeamNameLabel)
    containerView.addSubview(awayTeamNameLabel)
    
    containerView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    matchInfoLabel.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.greaterThanOrEqualTo(20)
    }
    
    homeTeamLogoImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalTo(matchInfoLabel.snp.leading).offset(-10)
      $0.size.equalTo(23)
    }
    
    homeTeamNameLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.centerY.equalToSuperview()
      $0.trailing.lessThanOrEqualTo(homeTeamLogoImageView.snp.leading).offset(-16)
//      $0.trailing.lessThanOrEqualTo(matchInfoLabel.snp.leading).offset(-16)
    }
    
    awayTeamLogoImageView.snp.makeConstraints {
      $0.leading.equalTo(matchInfoLabel.snp.trailing).offset(10)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(23)
    }
    
    awayTeamNameLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-16)
      $0.centerY.equalToSuperview()
      $0.leading.greaterThanOrEqualTo(awayTeamLogoImageView.snp.trailing).offset(16)
//      $0.leading.greaterThanOrEqualTo(matchInfoLabel.snp.trailing).offset(16)
    }
  }
  
  private func setLogoImage(_ fixture: Fixture) {
    guard let teams  = fixture.teams else { return }
    if let logoURL = teams[.away]?.logoURL,
       let url = URL(string: logoURL) {
      awayTeamLogoImageView.kf.setImage(with: url, options: [.transition(.fade(0.7))])
    }

    if let logoURL = teams[.home]?.logoURL,
       let url = URL(string: logoURL) {
      homeTeamLogoImageView.kf.setImage(with: url, options: [.transition(.fade(0.7))])
    }
  }
  
  private func setTitle(_ fixture: Fixture) {
    guard let teams = fixture.teams else { return }
    if let awayTitle = teams[.away]?.name {
      awayTeamNameLabel.text = awayTitle
    }
    if let homeTitle = teams[.home]?.name {
      homeTeamNameLabel.text = homeTitle
    }
  }
  
  private func setMatchInfo(_ fixture: Fixture) {
    guard let status = fixture.status,
          let matchDay = fixture.matchDay,
          let goals = fixture.goals else { return }
    
    let (matchText, kernValue, font): (String, CGFloat, UIFont)  = {
      switch status {
      case .scheduled(.toBeDefined):
        return (LocalizedStrings.TabBar.Matches.toBeDefined.localizedValue, 1, .monospacedDigitSystemFont(ofSize: 14, weight: .regular))
      case .scheduled(.notStarted):
        return ("\(matchDay.toString(format: .HHmm))", 0, .monospacedDigitSystemFont(ofSize: 14, weight: .regular))
      case .inPlay, .finished:
        let homeGoal = goals[.home] ?? 0
        let awayGoal = goals[.away] ?? 0
        return ("\(String(describing: homeGoal ?? 0)):\(String(describing: awayGoal ?? 0))", 1.5, .monospacedDigitSystemFont(ofSize: 16, weight: .semibold))
      case .postponed:
        return (LocalizedStrings.TabBar.Matches.postponed.localizedValue, 1, .monospacedDigitSystemFont(ofSize: 14, weight: .regular))
      case .cancelled:
        return (LocalizedStrings.TabBar.Matches.cancelled.localizedValue, 1, .monospacedDigitSystemFont(ofSize: 14, weight: .regular))
      case .abandoned:
        return (LocalizedStrings.TabBar.Matches.abandoned.localizedValue, 1, .monospacedDigitSystemFont(ofSize: 14, weight: .regular))
      case .notPlayed:
        return (LocalizedStrings.TabBar.Matches.notPlayed.localizedValue, 1, .monospacedDigitSystemFont(ofSize: 14, weight: .regular))
      }
    }()
    
    let attributedString = NSMutableAttributedString(
      string: matchText,
      attributes: [
        NSAttributedString.Key.kern: kernValue,
        NSAttributedString.Key.font: font
      ]
    )
    matchInfoLabel.attributedText = attributedString
  }
  
  @objc private func cellTapped() {
    print("cell tapped")
  }
}
