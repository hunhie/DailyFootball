//
//  StandingsTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/24.
//

import Foundation
import RealmSwift

final class StandingsTable: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var season: Int = 0
  @Persisted var standings: List<StandingTable>
  @Persisted var update: Date
  
  convenience init(id: Int, season: Int, standings: List<StandingTable>) {
    self.init()
    self.id = id
    self.season = season
    self.standings = standings
  }
}
