//
//  Country.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

struct Country: Hashable {
  let name: String
  let code: String?
  let flagURL: String?
  
  static func == (lhs: Country, rhs: Country) -> Bool {
    return lhs.name == rhs.name
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}
