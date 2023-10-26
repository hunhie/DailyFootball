//
//  BaseViewController.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/29.
//

import UIKit

class BaseViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setBackgroundColor(with: .background)
  }
  
  func setBackgroundColor(with: UIColor.ColorAsset) {
    view.backgroundColor = UIColor.appColor(for: with)
  }
}
