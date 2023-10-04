//
//  CompetitionGroup.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation

struct CompetitionGroup: Hashable {
  var id = UUID()
  var title: String
  var logoURL: String
  var competitions: [Competition]
  var isExpanded: Bool = false
  
  static func == (lhs: CompetitionGroup, rhs: CompetitionGroup) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
