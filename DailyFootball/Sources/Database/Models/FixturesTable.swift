//
//  FixturesTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class FixturesTable: EmbeddedObject {
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
