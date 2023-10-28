//
//  CompetitionTopScorersTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

final class LeagueTopScorersTable: Object {
  @Persisted(primaryKey: true) var id: String
  @Persisted var season: String
  @Persisted var topScorers: List<TopScorerTable>
  @Persisted var update: Date = Date()

  var competition: CompetitionTable? {
    LinkingObjects(fromType: CompetitionTable.self, property: "id").first
  }
}
