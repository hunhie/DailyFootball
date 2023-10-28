//
//  CompetitionGroup.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation

struct CompetitionGroup: Hashable {
  var country: Country
  var competitions: [Competition]
  var isExpanded: Bool = false
  
  static func == (lhs: CompetitionGroup, rhs: CompetitionGroup) -> Bool {
    return lhs.country.name == rhs.country.name && lhs.isExpanded == rhs.isExpanded
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(country.name)
    hasher.combine(isExpanded)
  }
}
