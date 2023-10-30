//
//  LeagueDetailHeaderView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/23.
//

import UIKit

final class LeagueDetailHeaderView: DynamicHeaderView {
  
  private let backgroundImageView: UIImageView = {
      let view = UIImageView()
      view.contentMode = .scaleAspectFill
      view.clipsToBounds = true
      return view
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let logoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    return view
  }()
  
  private let titleLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 23, weight: .heavy)
    view.numberOfLines = 2
    view.textAlignment = .center
    return view
  }()
  
  private let countryLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
    return view
  }()
  
  private let competition: Competition
  
  override var headerHeight: CGFloat {
    210
  }
  
  init(competition: Competition) {
    self.competition = competition
    super.init(frame: .zero)
    
    backgroundColor = UIColor.appColor(for: .background)
    
    setComponents()
    setConstaints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setComponents() {
    if let url = URL(string: competition.info.logoURL) {
      logoImageView.kf.setImage(with: url)
    }
    
    titleLabel.text = competition.info.name
    countryLabel.text = competition.country.name
  }
  
  private func setConstaints() {
    addSubview(containerView)
//    containerView.addSubview(logoImageView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(countryLabel)
    
    containerView.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
      make.width.lessThanOrEqualToSuperview().multipliedBy(0.9)
    }
    
//    logoImageView.snp.makeConstraints { make in
//      make.top.equalToSuperview()
//      make.centerX.equalToSuperview()
//      make.height.equalTo(50)
//    }
    
    titleLabel.snp.makeConstraints { make in
//      make.top.equalTo(logoImageView.snp.bottom).offset(20)
      make.top.equalToSuperview()
      make.leading.trailing.lessThanOrEqualToSuperview().inset(20)
      make.centerX.equalToSuperview()
    }
    
    countryLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.centerX.bottom.equalToSuperview()
    }
  }
}
