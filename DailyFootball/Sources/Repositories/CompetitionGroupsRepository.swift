//
//  CompetitionGroupsRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class CompetitionGroupsRepository {
  
  private var realm: Realm? {
    do {
      let realm = try Realm()
      return realm
    } catch {
      print("Error initializing realm: \(error)")
      return nil
    }
  }
  
  private lazy var apiManager: APIFootballManager = {
    return APIFootballManager()
  }()
  
  public func fetchData(completion: @escaping (Result<Results<CompetitionTable>, CompetitionGroupsRepositoryError>) -> ()) {
    fetchFromDB { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let response):
        completion(.success(response))
      case .failure:
        self.fetchFromAPIAndSave { result in
          switch result {
          case .success(let response):
            completion(.success(response))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
    }
  }
}

//MARK: - DataSource
extension CompetitionGroupsRepository {
  private func fetchFromDB(completion: @escaping (Result<Results<CompetitionTable>, CompetitionGroupsRepositoryError>) -> ()) {
    guard let realm else {
      completion(.failure(.realmError(.initializedFailed)))
      return
    }
    let data = realm.objects(CompetitionTable.self)
    if data.isEmpty {
      completion(.failure(.realmError(.DataEmpty)))
    } else {
      completion(.success(data))
    }
  }
  
  private func saveToDB(response: APIResponseLeagues) throws {
    guard let realm else { throw CompetitionGroupsRepositoryError.realmError(.initializedFailed) }
    
    let competitionTables = leagueTableFromAPIResponseLeagues(leaguesResponse: response)
    
    do {
      try realm.write {
        realm.add(competitionTables, update: .modified)
      }
    } catch {
      throw CompetitionGroupsRepositoryError.realmError(.writeFailed)
    }
  }
  
  private func fetchFromAPIAndSave(completion: @escaping (Result<Results<CompetitionTable>, CompetitionGroupsRepositoryError>) -> ()) {
    apiManager.request(.leagues) { [weak self] (result: Result<APIResponseLeagues, APIFootballError>) in
      guard let self else { return }
      switch result {
      case .success(let response):
        do {
          try self.saveToDB(response: response)
          self.fetchFromDB(completion: completion)
        } catch let error as RealmError {
          completion(.failure(.realmError(error)))
        } catch {
          completion(.failure(.unknownError))
        }
      case .failure(let apiError):
        completion(.failure(.apiError(apiError)))
      }
    }
  }
}

//MARK: - Helper
extension CompetitionGroupsRepository {
  private func leagueTableFromAPIResponseLeagues(leaguesResponse: APIResponseLeagues) -> [CompetitionTable] {
    let leagueTables: [CompetitionTable] = leaguesResponse.response.compactMap { response in
      let league = response.league
      let country = CountryTable(name: response.country.name, code: response.country.code, flag: response.country.flag)
      
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
      
      return CompetitionTable(id: league.id, name: league.name, type: league.type.rawValue, logo: league.logo, country: country, seasons: seasons)
    }
    
    return leagueTables
  }
  
//  private func competitionGroupsFromLeagueTable(leagueTables: Results<CompetitionTable>) -> [CompetitionGroup] {
//    let groudpedLeagueTablesByCountry = Dictionary(grouping: leagueTables) { $0.country?.name ?? ""}
//    
//    let competitionGroups = groudpedLeagueTablesByCountry.map { (countryName, tables) in
//      let competitions = tables.map { Competition(id: $0.id, title: $0.name, logoURL: $0.logo ?? "", type: $0.type) }
//      let sortedCompetitions = competitions.sorted { $0.id < $1.id }
//      let countryLogo = tables.first?.country?.flag ?? ""
//      
//      return CompetitionGroup(title: countryName, logoURL: countryLogo, competitions: sortedCompetitions)
//    }
//    
//    let sortedCompetitionGroups = competitionGroups.sorted { $0.title < $1.title }
//    return sortedCompetitionGroups
//  }
}

//MARK: - Error Case
extension CompetitionGroupsRepository {
  enum CompetitionGroupsRepositoryError: Error {
    case realmError(RealmError)
    case apiError(APIFootballError)
    case unknownError
  }
}
