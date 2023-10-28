//
//  Utils.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

final class Utils {
  static func getAppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
  }
  
  static func getBuildVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as! String
  }
}
