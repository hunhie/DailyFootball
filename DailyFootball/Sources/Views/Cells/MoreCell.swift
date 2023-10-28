//
//  MoreCell.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit

final class MoreCell: UITableViewCell {
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapActionHandler)))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var tapAction: (() -> Void)?
  
  @objc func tapActionHandler() {
    tapAction?()
  }
}
