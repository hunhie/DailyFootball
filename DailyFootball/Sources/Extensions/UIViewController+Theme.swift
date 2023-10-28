//
//  UIViewController+Extension.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import UIKit

extension UIViewController {
  func AppearanceCheck(_ viewController: UIViewController) {
    let isDarkTheme = UserDefaults.standard.bool(forKey: "isDarkTheme")
    view.window?.overrideUserInterfaceStyle = isDarkTheme ? .dark : .light
  }
}
