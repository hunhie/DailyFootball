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
          fixtures: FixturesInfoTable(
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
        let seasonTable = SeasonTable(uid: "\(league.id) + \(season.year)",id: league.id, year: season.year, start: Date.fromString(season.start, format: .YYYYMMdd(separator: "-")), end: Date.fromString(season.end, format: .YYYYMMdd(separator: "-")), current: season.current, coverage: coverage)
        seasons.append(seasonTable)
      }
      return CompetitionTable(id: league.id, info: CompetitionInfoTable(id: league.id, name: league.name, type: league.type.rawValue, logoURL: league.logo), country: country, seasons: seasons)
    }
    
    return leagueTables
  }
}

//MARK: - Error Case
extension CompetitionGroupsRepository {
  enum CompetitionGroupsRepositoryError: Error {
    case realmError(RealmError)
    case apiError(APIFootballError)
    case unknownError
  }
}
