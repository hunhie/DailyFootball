//
//  FixtureGroupByCompetition.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct FixtureGroupByCompetition: Hashable {
  let season: String
  let info: CompetitionInfo
  let country: Country
  let fixtures: [Fixture]
  var isExpanded: Bool = false
  
  static func == (lhs: FixtureGroupByCompetition, rhs: FixtureGroupByCompetition) -> Bool {
    lhs.info.id == rhs.info.id && lhs.isExpanded == rhs.isExpanded
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(info.id)
    hasher.combine(isExpanded)
  }
}
