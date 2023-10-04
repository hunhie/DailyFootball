//
//  TimeInterval.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation

extension TimeInterval {
  static func hours(_ count: Double) -> TimeInterval {
    return count * 3600
  }
  
  static func days(_ count: Double) -> TimeInterval {
    return hours(24) * count
  }
  
  static func weeks(_ count: Double) -> TimeInterval {
    return days(7) * count
  }
  
  static func months(_ count: Double) -> TimeInterval {
    return days(30) * count
  }
}
