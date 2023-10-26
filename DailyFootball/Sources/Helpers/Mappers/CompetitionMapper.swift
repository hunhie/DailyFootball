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
        coverage: coverage // 여기에 변환된 Coverage 정보를 추가합니다.
      )
    }
  }
  
  
  static func toEntity(from table: Results<FollowedCompetitionTable>) -> [Competition] {
    let competitions: [Competition] = table.map {
      Competition(
        id: $0.id,
        title: $0.title,
        logoURL: $0.logoURL,
        type: $0.type,
        country: $0.country,
        isFollowed: true,
        season: mapSeasons(from: $0.seasons) // 여기서 mapSeasons 함수를 사용하여 SeasonTable을 Competition.Season으로 변환합니다.
      )
    }
    return competitions
  }
}
