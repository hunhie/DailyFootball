//
//  ThemeManager.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

final class ThemeManager {
  
  static let shared = ThemeManager()
  
  private init() {
    let isDarkTheme = UserDefaults.standard.bool(forKey: "isDarkTheme")
    currentTheme = isDarkTheme ? .dark : .light
  }
  
  var currentTheme: Theme = .light {
    didSet {
      switch currentTheme {
      case .dark:
        UserDefaults.standard.set(true, forKey: "isDarkTheme")
      case .light:
        UserDefaults.standard.set(false, forKey: "isDarkTheme")
      }
    }
  }
}

extension ThemeManager {
  enum Theme {
    case light
    case dark
  }
}
