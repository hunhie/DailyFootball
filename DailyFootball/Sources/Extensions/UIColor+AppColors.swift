//
//  UIColor+AppColors.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/20.
//

import UIKit

extension UIColor {
  enum ColorAsset: String, CaseIterable {
    case background = "background"
    case subBackground = "backgroundSub"
    case accessory = "accessory"
    case accentColor = "accentColor"
    case accentDarkAndBlack = "accentDarkAndBlack"
    case accentDarkAndWhite = "accentDarkAndWhite"
    
    var uiColor: UIColor {
      return UIColor(named: self.rawValue) ?? {
        fatalError("Failed to load the color named \(self.rawValue)")
      }()
    }
  }
  
  static func appColor(for asset: ColorAsset) -> UIColor {
    return asset.uiColor
  }
}
