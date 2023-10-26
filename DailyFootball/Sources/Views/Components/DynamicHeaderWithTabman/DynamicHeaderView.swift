//
//  DynamicHeaderView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/23.
//

import UIKit
import Kingfisher

protocol DynamicHeaderViewProtocol: AnyObject {
  var headerHeight: CGFloat { get }
}

class DynamicHeaderView: UIView, DynamicHeaderViewProtocol {
  var headerHeight: CGFloat {
    0
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
