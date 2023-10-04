//
//  LeaguesRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class LeaguesRepository {
  static let shared = LeaguesRepository()
  
  private init() { }
  
  private var realm: Realm? {
    do {
      return try Realm()
    } catch {
      print("Failed to initialize Realm: \(error)")
      return nil
    }
  }
  
  func save(leaguesResponse: APIResponseLeagues) {
    guard let realm else {
      print("Realm initialization failed.")
      return
    }
    
    let leagueTables: [LeagueTable] = leaguesResponse.response.compactMap { response in
      let league = response.league
      let country = CountryTable(name: response.country.name, code: response.country.code, flag: response.country.flag, updateDate: <#Date#>)
      
      let seasons = List<SeasonTable>()
      response.seasons.forEach { season in
        let coverage = CoverageTable(
          fixtures: FixturesTable(
            events: season.coverage.fixtures.events,
            lineups: season.coverage.fixtures.lineups,
            statisticsFixtures: season.coverage.fixtures.statisticsFixtures,
            statisticsPlayers: season.coverage.fixtures.statisticsPlayers),
          standings: season.coverage.standings,
          players: season.coverage.players,
          topScorers: season.coverage.topScorers,
          topAssists: season.coverage.topAssists,
          topCards: season.coverage.topCards,
          injuries: season.coverage.injuries,
          predictions: season.coverage.predictions,
          odds: season.coverage.odds
        )
        
        let seasonTable = SeasonTable(year: season.year, start: season.start.toDate(), end: season.end.toDate(), current: season.current, coverage: coverage)
        seasons.append(seasonTable)
      }
      
      return LeagueTable(id: league.id, name: league.name, type: league.type.rawValue, logo: league.logo, country: country, seasons: seasons)
    }
    
    do {
      try realm.write {
        realm.add(leagueTables, update: .all)
      }
    } catch {
      print("Failed to write leagues to Realm: \(error)")
    }
  }
}
