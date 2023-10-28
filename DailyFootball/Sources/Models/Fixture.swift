//
//  Fixture.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct Fixture {
  let id: Int
  let matchDay: Date?
  let round: String
  let venue: Venue
  let status: MatchStatus
  let teams: Teams
  let goals: Goals
  let score: Score
}

typealias Score = [MatchPeriod: [HomeOrAway: Int?]]
typealias Goals = [HomeOrAway: Int?]
typealias Teams = [HomeOrAway: Team]
