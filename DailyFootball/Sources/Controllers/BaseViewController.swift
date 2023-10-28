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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    AppearanceCheck(self)
  }
  
  func setBackgroundColor(with: UIColor.ColorAsset) {
    view.backgroundColor = UIColor.appColor(for: with)
  }
}
