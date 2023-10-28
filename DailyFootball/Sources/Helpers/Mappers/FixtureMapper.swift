//
//  FixtureMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

struct FixtureMapper: EntityMapperProtocol {
  typealias TableType = FixtureTable
  typealias EntityType = FixtureGroup
  
  static func mapEntity(from table: TableType) throws -> EntityType {
    do {
      let fixtures: [Fixture] = try table.fixtureData.compactMap { data in
        let timestamp = data.timestamp
        let matchDay = Date.fromTimeStamp(timestamp)
        let venue = try VenueMapper.mapEntity(from: data.venue)
        let status = try MatchStatusMapper.mapEntity(from: data.status)
        let teams = try TeamMapper.mapEntity(from: data.teams)
        let goals = try GoalsMapper.mapEntity(from: data.goals)
        let score = try ScoreMapper.mapEntity(from: data.score)
        let round = data.round ?? ""
        let roundComponents = round.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let roundNumber = roundComponents.filter { !$0.isEmpty }.joined()
        return Fixture(id: data.fixtureId, matchDay: matchDay, round: roundNumber, venue: venue, status: status, teams: teams, goals: goals, score: score)
      }
      let info = CompetitionMapper.mapCompetitionInfo(from: table.info)
      let country = CountryMapper.mapCountry(from: table.country)
      return FixtureGroup(season: table.season, info: info, country: country, fixtures: fixtures)
    } catch {
      throw MappingError.missingData
    }
  }
}
