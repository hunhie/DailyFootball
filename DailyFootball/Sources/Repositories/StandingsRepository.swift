//
//  StandingsRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/24.
//

import Foundation
import RealmSwift

final class StandingsRepository {
  
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
  
  public func fetchData(season: Int, id: Int, completion: @escaping (Result<List<StandingTable>, StandingsRepositoryError>) -> ()) {
    fetchFromDB(season: season, id: id) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        if let response = response.first {
          completion(.success(response.standings))
        }
      case .failure:
        self.fetchFromAPIAndSave(season: season, id: id) { result in
          switch result {
          case .success(let response):
            if let response = response.first {
              completion(.success(response.standings))
            }
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
    }
  }
  
  private func fetchFromDB(season: Int, id: Int, completion: @escaping (Result<Results<StandingsTable>, StandingsRepositoryError>) -> ()) {
    guard let realm = self.realm else {
      completion(.failure(.realmError(.initializedFailed)))
      return
    }
    let data = realm.objects(StandingsTable.self).filter("season == \(season) AND id == \(id)")
    
    if data.isEmpty {
      completion(.failure(.realmError(.DataEmpty)))
      return
    }
    
    if let latestData = data.first {
      let currentDate = Date()
      let interval = currentDate.timeIntervalSince(latestData.update)
      
      if interval > 3600 {
        completion(.failure(.realmError(.outdatedData)))
        return
      } else {
        completion(.success(data))
        return
      }
    }
  }
  
  private func saveToDB(response: APIResponseStandings) throws {
    guard let realm else { throw StandingsRepositoryError.realmError(.initializedFailed) }
    
    let standingsTable = standingsTableFromAPIResponseStandings(standingsResponse: response)
    
    do {
      try realm.write {
        realm.add(standingsTable, update: .modified)
      }
    } catch {
      throw StandingsRepositoryError.realmError(.writeFailed)
    }
  }
  
  private func fetchFromAPIAndSave(season: Int, id: Int, completion: @escaping (Result<Results<StandingsTable>, StandingsRepositoryError>) -> ()) {
    apiManager.request(.standings(season: season, id: id)) { [weak self] (result: Result<APIResponseStandings, APIFootballError>) in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        do {
          try self.saveToDB(response: response)
          self.fetchFromDB(season: season, id: id, completion: completion)
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

//MARK: - Error Case
extension StandingsRepository {
  enum StandingsRepositoryError: Error {
    case realmError(RealmError)
    case apiError(APIFootballError)
    case unknownError
  }
}

extension StandingsRepository {
  private func standingsTableFromAPIResponseStandings(standingsResponse: APIResponseStandings) -> [StandingsTable] {
    let standingsTable: [StandingsTable] = standingsResponse.response.compactMap { response in
      let league = response.league
      let id = league.id
      let season = league.season
      
      let standingsList = List<StandingTable>()
      league.standings.forEach { standings in
        standings.forEach { standing in
          let standingTable = StandingTable()
          standingTable.rank = standing.rank
          standingTable.points = standing.points
          standingTable.goalsDiff = standing.goalsDiff
          standingTable.group = standing.group
          standingTable.form = standing.form
          standingTable.status = standing.status
          standingTable.desc = standing.description
          
          let teamTable = TeamTable()
          teamTable.id = standing.team.id
          teamTable.name = standing.team.name
          teamTable.logo = standing.team.logo
          
          standingTable.team = teamTable
          
          let allRecord = GameRecordTable()
          allRecord.played = standing.all.played
          allRecord.win = standing.all.win
          allRecord.draw = standing.all.draw
          allRecord.lose = standing.all.lose
          allRecord.goalsFor = standing.all.goals.goalsFor
          allRecord.goalsAgainst = standing.all.goals.against
          
          standingTable.all = allRecord
          
          let homeRecord = GameRecordTable()
          homeRecord.played = standing.home.played
          homeRecord.win = standing.home.win
          homeRecord.draw = standing.home.draw
          homeRecord.lose = standing.home.lose
          homeRecord.goalsFor = standing.home.goals.goalsFor
          homeRecord.goalsAgainst = standing.home.goals.against
          
          standingTable.home = homeRecord
          
          let awayRecord = GameRecordTable()
          awayRecord.played = standing.away.played
          awayRecord.win = standing.away.win
          awayRecord.draw = standing.away.draw
          awayRecord.lose = standing.away.lose
          awayRecord.goalsFor = standing.away.goals.goalsFor
          awayRecord.goalsAgainst = standing.away.goals.against
          
          standingTable.away = awayRecord
          
          standingsList.append(standingTable)
        }
      }
      return StandingsTable(id: id, season: season, standings: standingsList)
    }
    
    return standingsTable
  }
}
