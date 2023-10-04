//
//  FollowingCompetitionCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import UIKit
import Kingfisher
import SnapKit

final class FollowingCompetitionCell: UICollectionViewCell {
  
  private let logoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleToFill
    return view
  }()
  
  private let titleLabel: UILabel = {
    let view = UILabel()
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
  
  private func setCellUI() {
    backgroundColor = .white
    layer.cornerRadius = 12
    clipsToBounds = true
  }
  
  private func setLogoImage(_ data: Competition) {
    if let imageSource = URL(string: data.logoURL) {
      logoImageView.kf.setImage(with: imageSource)
    }
  }
  
  private func setTitle(_ data: Competition) {
    titleLabel.text = data.title
  }
  
  private func setConstraints() {
    addSubview(logoImageView)
    addSubview(titleLabel)
    
    logoImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(20)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(logoImageView).offset(20)
    }
  }
}
