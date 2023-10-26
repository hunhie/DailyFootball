//
//  Player.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

struct Player: Hashable {
  let id: Int
  let name: String
  let firstname: String?
  let lastname: String?
  let age: Int
  let birthDate: String?
  let nationality: String?
  let height: String?
  let weight: String?
  let injured: Bool
  let photo: String
  
  static func == (lhs: Player, rhs: Player) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
