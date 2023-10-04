//
//  Competition.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation

struct Competition: Hashable {
  var id = UUID()
  var title: String
  var logoURL: String
  
  static func == (lhs: Competition, rhs: Competition) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
