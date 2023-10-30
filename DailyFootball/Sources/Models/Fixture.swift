//
//  Fixture.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct Fixture: Hashable {
  let id: Int
  let matchDay: Date?
  let round: String
  let venue: Venue?
  let status: MatchStatus?
  let teams: Teams?
  let goals: Goals?
  let score: Score?
  
  static func == (lhs: Fixture, rhs: Fixture) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

typealias Score = [MatchPeriod: [HomeOrAway: Int?]]
typealias Goals = [HomeOrAway: Int?]
typealias Teams = [HomeOrAway: Team]
