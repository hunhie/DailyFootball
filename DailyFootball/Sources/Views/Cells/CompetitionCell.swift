//
//  CompetitionCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import UIKit
import Kingfisher
import SnapKit

final class CompetitionCell: UITableViewCell {
  
  enum FollowButtonState {
    case follow
    case following
  }
  
  private lazy var dividerView: DividerView = {
    let view = DividerView()
    view.setBackgroundColor(backgroundColor: .systemGray5)
    return view
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  private lazy var logoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.tintColor = .black
    return view
  }()
  
  private lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.font = .systemFont(ofSize: 15, weight: .regular)
    view.numberOfLines = 1
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return view
  }()
  
  private lazy var followButton: StatefulButton = {
    let config = UIButton.Configuration.plain()
    let view = StatefulButton<FollowButtonState>(config: config)
    
    var followAttrString = AttributedString.init("팔로우")
    followAttrString.font = .systemFont(ofSize: 14, weight: .bold)
    
    var followingAttrString = AttributedString.init("팔로잉")
    followingAttrString.font = .systemFont(ofSize: 14, weight: .bold)
    
    view.setAttributedTitleWithColor(followAttrString, .white, forState: .follow)
    view.setAttributedTitleWithColor(followingAttrString, .white, forState: .following)
    
    view.setBackgroundColor(.systemBlue, forState: .follow)
    view.setBackgroundColor(.systemGray3, forState: .following)
    
    view.layer.cornerRadius = 12
    view.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setConstraints()
    setCellUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var isFollowed: Bool = false {
    didSet {
      setFollowButton(isFollowed)
    }
  }
  
  var followAction: ((Bool) -> ())?
  
  public func configureView(with competition: Competition) {
    isFollowed = competition.isFollowed
    setLogoImage(competition)
    setTitle(competition)
  }
  
  private func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(dividerView)
    containerView.addSubview(logoImageView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(followButton)
    
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.horizontalEdges.equalToSuperview().inset(14)
      make.bottom.equalToSuperview()
    }
    
    dividerView.snp.makeConstraints { make in
      make.top.horizontalEdges.equalToSuperview()
      make.height.equalTo(1)
    }
    
    logoImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(20)
      make.size.equalTo(25)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(logoImageView.snp.trailing).offset(20)
      make.trailing.lessThanOrEqualTo(followButton.snp.leading).offset(-20)
    }
    
    followButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().offset(-20)
    }
  }
  
  private func setCellUI() {
    backgroundColor = .clear
    selectionStyle = .none
  }
  
  private func setLogoImage(_ data: Competition) {
    if let imageSource = URL(string: data.logoURL) {
      logoImageView.kf.setImage(with: imageSource)
    }
  }
  
  private func setTitle(_ data: Competition) {
    titleLabel.text = data.title
  }
  
  private func setFollowButton(_ isFollowed: Bool) {
    followButton.currentState = isFollowed ? .following : .follow
  }
  
  @objc func followButtonTapped() {
    self.followAction?(isFollowed)
  }
  
  public func applyRoundedCorners(isLast: Bool) {
    if isLast {
      containerView.layer.cornerRadius = 16
      containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    } else {
      containerView.layer.cornerRadius = 0
      containerView.layer.maskedCorners = []
    }
  }
}


//final class CompetitionCell: UICollectionViewCell {
//
//  private lazy var dividerView: DividerView = {
//    let view = DividerView()
//    view.setBackgroundColor(backgroundColor: .systemGray5)
//    return view
//  }()
//
//  private lazy var logoImageView: UIImageView = {
//    let view = UIImageView()
//    view.contentMode = .scaleAspectFit
//    view.tintColor = .black
//    return view
//  }()
//
//  private lazy var titleLabel: UILabel = {
//    let view = UILabel()
//    view.numberOfLines = 1
//    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//    return view
//  }()
//
//  private lazy var followButton: UIButton = {
//    let view = UIButton()
//    var config = UIButton.Configuration.filled()
//    var titleAttr = AttributedString.init("팔로우")
//    titleAttr.font = .systemFont(ofSize: 14, weight: .bold)
//    config.attributedTitle = titleAttr
//    view.configuration = config
//    view.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
//    return view
//  }()
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//
//    setConstraints()
//    setCellUI()
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  public func configureView(with competition: Competition) {
//    self.competition = competition
//    setLogoImage(competition)
//    setTitle(competition)
//  }
//
//  var competition: Competition?
//
//  var followAction: ((Competition) -> ())?
//
//  private func setConstraints() {
//    contentView.addSubview(dividerView)
//    contentView.addSubview(logoImageView)
//    contentView.addSubview(titleLabel)
//    contentView.addSubview(followButton)
//
//    dividerView.snp.makeConstraints { make in
//      make.top.horizontalEdges.equalToSuperview()
//      make.height.equalTo(1)
//    }
//
//    logoImageView.snp.makeConstraints { make in
//      make.centerY.equalToSuperview()
//      make.leading.equalToSuperview().offset(20)
//      make.size.equalTo(25)
//    }
//
//    titleLabel.snp.makeConstraints { make in
//      make.centerY.equalToSuperview()
//      make.leading.equalTo(logoImageView.snp.trailing).offset(20)
//      make.trailing.lessThanOrEqualTo(followButton.snp.leading).offset(-20)
//    }
//
//    followButton.snp.makeConstraints { make in
//      make.centerY.equalToSuperview()
//      make.trailing.equalToSuperview().offset(-20)
//    }
//  }
//
//  private func setCellUI() {
//    backgroundColor = .white
//  }
//
//  private func setLogoImage(_ data: Competition) {
//    if let imageSource = URL(string: data.logoURL) {
//      logoImageView.kf.setImage(with: imageSource)
//    }
//  }
//
//  private func setTitle(_ data: Competition) {
//    titleLabel.text = data.title
//  }
//
//  @objc func followButtonTapped() {
//    guard let competition else { return }
//    self.followAction?(competition)
//  }
//
//  public func applyRoundedCorners(isLast: Bool) {
//    if isLast {
//      layer.cornerRadius = 12
//      layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//    } else {
//      layer.cornerRadius = 0
//      layer.maskedCorners = []
//    }
//  }
//}
