//
//  League.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation

struct Competition: Hashable {
  var id: Int
  var info: CompetitionInfo
  var country: Country
  var isFollowed: Bool
  var season: [Season]
  
  static func == (lhs: Competition, rhs: Competition) -> Bool {
    return lhs.id == rhs.id && lhs.isFollowed == rhs.isFollowed
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(isFollowed)
  }
  
  struct Season {
    let year: Int
    let current: Bool
    let coverage: Coverage?
    
    struct Coverage {
      let fixtures: Fixtures
      let standings: Bool
      let players: Bool
      let topScorers: Bool
      let topAssists: Bool
      let topCards: Bool
      let injuries: Bool
      let predictions: Bool
      let odds: Bool
      
      struct Fixtures {
        let events: Bool
        let lineups: Bool
        let statisticsFixtures: Bool
        let statisticsPlayers: Bool
      }
    }
  }
}
