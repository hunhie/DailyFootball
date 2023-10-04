//
//  DataValidityDuration.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation

enum DataValidityDuration {
  case league
  
  var duration: TimeInterval {
    switch self {
    case .league: return .days(1)
    }
  }
}
