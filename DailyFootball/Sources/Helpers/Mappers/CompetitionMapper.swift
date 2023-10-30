//
//  CompetitionMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/12.
//

import Foundation
import RealmSwift

struct CompetitionMapper {
  static func mapCoverage(from coverageTable: CoverageTable?) -> Competition.Season.Coverage? {
    guard let coverageTable = coverageTable else { return nil }
    
    let fixtures = Competition.Season.Coverage.Fixtures(
      events: coverageTable.fixtures!.events,
      lineups: coverageTable.fixtures!.lineups,
      statisticsFixtures: coverageTable.fixtures!.statisticsFixtures,
      statisticsPlayers: coverageTable.fixtures!.statisticsPlayers
    )
    
    return Competition.Season.Coverage(
      fixtures: fixtures,
      standings: coverageTable.standings,
      players: coverageTable.players,
      topScorers: coverageTable.topScorers,
      topAssists: coverageTable.topAssists,
      topCards: coverageTable.topCards,
      injuries: coverageTable.injuries,
      predictions: coverageTable.predictions,
      odds: coverageTable.odds
    )
  }
  
  
  static func mapSeasons(from seasonTables: List<SeasonTable>) -> [Competition.Season] {
    return seasonTables.map { seasonTable in
      let coverage = mapCoverage(from: seasonTable.coverage)
      return Competition.Season(
        year: seasonTable.year,
        current: seasonTable.current,
        coverage: coverage
      )
    }
  }
  
  static func mapCountry(from table: CountryTable?) -> Country {
    return Country(name: table?.name ?? "", code: table?.code ?? "", flagURL: table?.flag ?? "")
  }
  
  static func mapCompetitionInfo(from table: CompetitionInfoTable?) throws -> CompetitionInfo {
    guard let table else { throw MappingError.missingData }
    return CompetitionInfo(id: table.id, name: table.name , type: table.type , logoURL: table.logoURL ?? "")
  }
  
  static func mapCompetitions(from table: Results<FollowedCompetitionTable>) throws -> [Competition] {
    do {
      let competitions: [Competition] = try table.map {
        Competition(
          id: $0.id,
          info: try mapCompetitionInfo(from: $0.info),
          country: mapCountry(from: $0.country),
          isFollowed: true,
          season: mapSeasons(from: $0.seasons) // 여기서 mapSeasons 함수를 사용하여 SeasonTable을 Competition.Season으로 변환합니다.
        )
      }
      return competitions
    } catch {
      throw MappingError.missingData
    }
  }
}
