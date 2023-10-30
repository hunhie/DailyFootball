//
//  Standing.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/25.
//

import Foundation

struct Standing: Hashable {
  let rank: Int
  let team: Team
  let group: String
  let point: Int
  let goalsDiff: Int
  let description: String
  let all: GameRecord
  let home: GameRecord
  let away: GameRecord
  
  static func == (lhs: Standing, rhs: Standing) -> Bool {
    lhs.team.id == rhs.team.id && lhs.group == rhs.group && lhs.description == rhs.description
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(team.id)
    hasher.combine(group)
    hasher.combine(description)
  }
  
  struct GameRecord {
    let played: Int
    let win: Int
    let draw: Int
    let lose: Int
    let goalsFor: Int
    let goalsAgainst: Int
  }
}
