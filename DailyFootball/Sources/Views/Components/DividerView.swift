//
//  DividerView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import UIKit

final class DividerView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setBackgroundColor(backgroundColor: UIColor) {
    self.backgroundColor = backgroundColor
  }
}
