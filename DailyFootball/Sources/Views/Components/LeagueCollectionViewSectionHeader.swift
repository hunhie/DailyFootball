//
//  LeagueCollectionViewSectionHeader.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/29.
//

import UIKit
import SnapKit

final class LeagueCollectionViewSectionHeader: UICollectionReusableView {
  
  private lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.text = "섹션 헤더입니다."
    view.textColor = .black
    return view
  }()
  
  private lazy var editButton: UIButton = {
    let view = UIButton()
    view.setTitle("편집", for: .normal)
    view.isHidden = true
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)

    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setConstraints() {
    addSubview(titleLabel)
    addSubview(editButton)
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.centerY.equalToSuperview()
    }
    
    editButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-20)
      make.centerY.equalToSuperview()
    }
  }
  
  func showEditButton(_ show: Bool) {
    editButton.isHidden = !show
  }
}
