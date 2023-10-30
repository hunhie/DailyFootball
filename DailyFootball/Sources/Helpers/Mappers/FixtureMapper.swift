//
//  FixturesMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/29.
//

import Foundation
import RealmSwift

struct FixtureMapper: EntityMapperProtocol {
  typealias TableType = List<FixtureDetailTable>
  typealias EntityType = [Fixture]
  
  static func mapEntity(from table: List<FixtureDetailTable>) -> [Fixture] {
    let sortedTable = table.sorted(by: { $0.timestamp < $1.timestamp })
    
    return sortedTable.compactMap { data in
      let matchDay = Date.fromTimeStamp(data.timestamp)
      let venue = VenueMapper.mapEntity(from: data.venue)
      let status = MatchStatusMapper.mapEntity(from: data.status)
      let teams = TeamMapper.mapEntity(from: data.teams)
      let goals = GoalsMapper.mapEntity(from: data.goals)
      let score = ScoreMapper.mapEntity(from: data.score)
      let round = data.round ?? ""
      let roundNumber = filterDigits(from: round)
      
      return Fixture(id: data.fixtureId, matchDay: matchDay, round: roundNumber, venue: venue, status: status, teams: teams, goals: goals, score: score)
    }
  }
  
  
  private static func filterDigits(from string: String) -> String {
    let roundComponents = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
    return roundComponents.filter { !$0.isEmpty }.joined()
  }
}
