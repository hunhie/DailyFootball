//
//  CompetitionGroupCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import UIKit
import Kingfisher
import SnapKit

final class CompetitionGroupCell: UICollectionViewCell {
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 12
    return view
  }()
  
  private let logoImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleToFill
    return view
  }()
  
  private let titleLabel: UILabel = {
    let view = UILabel()
    return view
  }()
  
  private let expansionArrowView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleToFill
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var tapAction: (() -> Void)?
  
  var isExpended: Bool = false {
    didSet {
      updateCornerRadiusForExpansionState(isExpanded: isExpended)
    }
  }
  
  public func configureView(with competitionGroup: CompetitionGroup) {
    isExpended = competitionGroup.isExpanded
    
    setLogoImage(competitionGroup)
    setTitle(competitionGroup)
  }
  
  private func setConstraints() {
    addSubview(containerView)
    containerView.addSubview(logoImageView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(expansionArrowView)
    
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.horizontalEdges.bottom.equalToSuperview()
    }
    
    logoImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(20)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(logoImageView).offset(20)
    }
    
    expansionArrowView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().offset(-20)
    }
  }
  
  private func setLogoImage(_ data: CompetitionGroup) {
    if let imageSource = URL(string: data.logoURL) {
      logoImageView.kf.setImage(with: imageSource)
    }
  }
  
  private func setTitle(_ data: CompetitionGroup) {
    titleLabel.text = data.title
  }
  
  private func updateCornerRadiusForExpansionState(isExpanded: Bool) {
    let allCorners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    let topCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    
    if !isExpanded {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
        self.containerView.layer.maskedCorners = allCorners
      }
    } else {
      containerView.layer.maskedCorners = topCorners
    }
  }
}
