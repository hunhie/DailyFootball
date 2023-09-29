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
    
    setBackgroundColor()
  }
  
  func setBackgroundColor() {
    view.backgroundColor = .systemBackground
  }
}
