//
//  CoverageTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class CoverageTable: EmbeddedObject {
  @Persisted var fixtures: FixturesTable
  @Persisted var standings: Bool
  @Persisted var players: Bool
  @Persisted var topScorers: Bool
  @Persisted var topAssists: Bool
  @Persisted var topCards: Bool
  @Persisted var injuries: Bool
  @Persisted var predictions: Bool
  @Persisted var odds: Bool
  
  convenience init(fixtures: FixturesTable, standings: Bool, players: Bool, topScorers: Bool, topAssists: Bool, topCards: Bool, injuries: Bool, predictions: Bool, odds: Bool) {
    self.init()
    self.fixtures = fixtures
    self.standings = standings
    self.players = players
    self.topScorers = topScorers
    self.topAssists = topAssists
    self.topCards = topCards
    self.injuries = injuries
    self.predictions = predictions
    self.odds = odds
  }
}
