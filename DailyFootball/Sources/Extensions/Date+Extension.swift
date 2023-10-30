//
//  Date+Extension.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

extension Date {
  enum DateError: Error {
    case failedToComputeDateRange
  }
  
  static func fromTimeStamp(_ timeStamp: Int?) -> Date? {
    guard let timeStamp else { return nil }
    return Date(timeIntervalSince1970: TimeInterval(timeStamp))
  }
  
  static func fromString(_ dateString: String, format: DateFormat) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = format.format
    return formatter.date(from: dateString)
  }
  
  func toString(format: DateFormat) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format.format
    return formatter.string(from: self)
  }
  
  func betweenDate() throws -> (start: Date, end: Date) {
    let calendar = Calendar.current
    guard let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self),
          let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self) else {
      throw DateError.failedToComputeDateRange
    }
    
    return (start: startDate, end: endDate.addingTimeInterval(-1))
  }
  
  
  enum DateFormat {
    case YYYYMMdd(separator: String)
    case MMddYYYY(separator: String)
    case ddMMYYYY(separator: String)
    case YYYYMMddHHmmss(separator: String)
    case MMddYYYYHHmmss(separator: String)
    case ddMMYYYYHHmmss(separator: String)
    case EEEddMMMYYYY(separator: String)
    case HHmm
    
    var format: String {
      switch self {
      case .YYYYMMdd(let separator):
        return "YYYY\(separator)MM\(separator)dd"
      case .MMddYYYY(let separator):
        return "MM\(separator)dd\(separator)YYYY"
      case .ddMMYYYY(let separator):
        return "dd\(separator)MM\(separator)YYYY"
      case .YYYYMMddHHmmss(let separator):
        return "YYYY\(separator)MM\(separator)dd HH:mm:ss"
      case .MMddYYYYHHmmss(let separator):
        return "MM\(separator)dd\(separator)YYYY HH:mm:ss"
      case .ddMMYYYYHHmmss(let separator):
        return "dd\(separator)MM\(separator)YYYY HH:mm:ss"
      case .EEEddMMMYYYY(let separator):
        return "EEE dd MMM\(separator)YYYY"
      case .HHmm:
        return "HH:mm"
      }
    }
  }
}
