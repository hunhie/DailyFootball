//
//  Scorer.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

struct Scorer: Hashable {
  let id: String
  let rank: Int
  let player: Player
  let goals: Int
  var isTiedWithPrevious: Bool = false
  
  static func == (lhs: Scorer, rhs: Scorer) -> Bool {
    lhs.player.id == rhs.player.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(player.id)
  }
}
