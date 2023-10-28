//
//  CoverageTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class CoverageTable: EmbeddedObject {
  @Persisted var fixtures: FixturesInfoTable?
  @Persisted var standings: Bool
  @Persisted var players: Bool
  @Persisted var topScorers: Bool
  @Persisted var topAssists: Bool
  @Persisted var topCards: Bool
  @Persisted var injuries: Bool
  @Persisted var predictions: Bool
  @Persisted var odds: Bool
  
  convenience init(fixtures: FixturesInfoTable?, standings: Bool, players: Bool, topScorers: Bool, topAssists: Bool, topCards: Bool, injuries: Bool, predictions: Bool, odds: Bool) {
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

final class FixturesInfoTable: EmbeddedObject {
  @Persisted var events: Bool
  @Persisted var lineups: Bool
  @Persisted var statisticsFixtures: Bool
  @Persisted var statisticsPlayers: Bool
  
  convenience init(events: Bool, lineups: Bool, statisticsFixtures: Bool, statisticsPlayers: Bool) {
    self.init()
    self.events = events
    self.lineups = lineups
    self.statisticsFixtures = statisticsFixtures
    self.statisticsPlayers = statisticsPlayers
  }
}
