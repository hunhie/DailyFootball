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

final class TeamTable: Object {
    @Persisted var id: Int
    @Persisted var name: String
    @Persisted var logo: String
}

final class StandingTable: Object {
    @Persisted var rank: Int
    @Persisted var team: TeamTable?
    @Persisted var points: Int
    @Persisted var goalsDiff: Int
    @Persisted var group: String
    @Persisted var form: String
    @Persisted var status: String
    @Persisted var desc: String?
    @Persisted var all: GameRecordTable?
    @Persisted var home: GameRecordTable?
    @Persisted var away: GameRecordTable?
}

final class GameRecordTable: Object {
    @Persisted var played: Int
    @Persisted var win: Int
    @Persisted var draw: Int
    @Persisted var lose: Int
    @Persisted var goalsFor: Int
    @Persisted var goalsAgainst: Int
}
