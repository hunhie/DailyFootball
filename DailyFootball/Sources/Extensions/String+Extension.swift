//
//  String+Extension.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation

extension String {
  func toDate(format: String = "yyyy-MM-dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: self)
  }
}
