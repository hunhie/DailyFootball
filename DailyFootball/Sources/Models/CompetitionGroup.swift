//
//  CompetitionGroup.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation

struct CompetitionGroup: Hashable {
  var title: String
  var logoURL: String
  var competitions: [Competition]
  var isExpanded: Bool = false
  
  static func == (lhs: CompetitionGroup, rhs: CompetitionGroup) -> Bool {
    return lhs.title == rhs.title && lhs.isExpanded == rhs.isExpanded
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(isExpanded)
  }
}
