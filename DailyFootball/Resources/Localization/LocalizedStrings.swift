//
//  LocalizedStrings.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/28.
//

import Foundation

protocol Localizable {
  var localizedValue: String { get }
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
  var localizedValue: String {
    return NSLocalizedString(rawValue, comment: "")
  }
}

enum LocalizedStrings {
  enum Common: String, Localizable {
    case ok = "common_ok"
    case cancel = "common_cancel"
  }
  
  enum TabBar {
    enum Leagues: String, Localizable {
      case title = "tab_leagues_title"
      case searchbarPlaceholder = "searchbar_placeholder"
    }
    
    enum Matches: String, Localizable {
      case title = "tab_matches_title"
    }
    
    enum Following: String, Localizable {
      case title = "tab_following_title"
    }
    
    enum News: String, Localizable {
      case title = "tab_news_title"
    }
    
    enum More: String, Localizable {
      case title = "tab_more_title"
    }
  }
}
