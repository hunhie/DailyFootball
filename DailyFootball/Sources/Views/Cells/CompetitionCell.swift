//
//  CompetitionCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import UIKit
import Kingfisher
import SnapKit

final class CompetitionCell: UICollectionViewCell {
  
  private let logoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleToFill
    return view
  }()
  
  private let titleLabel: UILabel = {
    let view = UILabel()
    return view
  }()
  
  private let followButton: UIButton = {
    let view = UIButton()
    view.setTitle("팔로우", for: .normal)
    view.setTitleColor(.black, for: .normal)
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setConstraints()
    setCellUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func configureView(with competition: Competition) {
    setLogoImage(competition)
    setTitle(competition)
  }
  
  private func setConstraints() {
    addSubview(logoImageView)
    addSubview(titleLabel)
    addSubview(followButton)
    
    logoImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(20)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(logoImageView).offset(20)
    }
    
    followButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().offset(-20)
    }
  }
  
  private func setCellUI() {
    backgroundColor = .white
  }
  
  private func setLogoImage(_ data: Competition) {
    if let imageSource = URL(string: data.logoURL) {
      logoImageView.kf.setImage(with: imageSource)
    }
  }
  
  private func setTitle(_ data: Competition) {
    titleLabel.text = data.title
  }
  
  public func applyRoundedCorners(isLast: Bool) {
    if isLast {
      // 마지막 셀일 경우 모서리 효과 적용
      layer.cornerRadius = 12
      layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    } else {
      // 그렇지 않은 경우 모서리 효과 제거
      layer.cornerRadius = 0
      layer.maskedCorners = []
    }
  }
}
