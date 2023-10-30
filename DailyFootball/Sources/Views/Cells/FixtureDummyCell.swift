//
//  FixtureDummyCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/29.
//

import UIKit

final class FixtureDummyCell: UITableViewCell {
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.appColor(for: .background)
    return view
  }()
  
  private let mainInfoLabel: UILabel = {
    let view = UILabel()
    view.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
    view.numberOfLines = 1
    view.textAlignment = .center
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    view.text = LocalizedStrings.TabBar.Matches.noFixtureAvailable.localizedValue
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setCellUI()
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setCellUI() {
    selectionStyle = .none
  }
  
  private func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(mainInfoLabel)
    
    containerView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    mainInfoLabel.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.greaterThanOrEqualToSuperview().multipliedBy(0.8)
    }
  }
}
