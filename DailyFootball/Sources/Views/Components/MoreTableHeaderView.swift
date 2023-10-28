//
//  MoreTableHeaderView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit

final class MoreTableHeaderView: UITableViewHeaderFooterView {
  
  private let containerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let titleLabel: UILabel = {
    let view = UILabel()
    view.textColor = UIColor.appColor(for: .subLabel)
    view.font = .systemFont(ofSize: 15, weight: .regular)
    return view
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setConstraints() {
    contentView.addSubview(containerView)
    containerView.addSubview(titleLabel)
    
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(8)
      make.horizontalEdges.centerY.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(20)
    }
  }
  
  func configureTitle(_ title: String) {
    titleLabel.text = title
  }
  
}
