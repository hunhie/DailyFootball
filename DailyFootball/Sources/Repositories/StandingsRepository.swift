//
//  StandingsRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/24.
//

import Foundation
import RealmSwift
import RxSwift

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
  
  func fetch(season: Int, id: Int) -> Single<List<StandingTable>> {
    return fetchFromDB(season: season, id: id)
      .catch { [weak self] error -> Single<List<StandingTable>> in
        guard let self = self else { return Single.error(error) }
        if let error = error as? StandingsRepositoryError,
           case .realmError = error {
          return fetchFromAPI(season: season, id: id)
            .flatMap { [weak self] value -> Single<List<StandingTable>> in
              guard let self = self else { return Single.error(error) }
              let dbTable = self.standingsTableFromAPIResponseStandings(standingsResponse: value)
              guard let data = dbTable.first else { return Single.error(error) }
              return self.saveToDB(response: value)
                .andThen(Single.just(data.standings))
            }
        } else {
          return Single.error(error)
        }
      }
  }
  
  
  private func fetchFromDB(season: Int, id: Int) -> Single<List<StandingTable>> {
    return Single.create { [weak self] single in
      guard let self,
            let realm else {
        single(.failure(StandingsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      
      let data = realm.objects(StandingsTable.self).filter("season == \(season) AND id == \(id)")
      if data.isEmpty {
        single(.failure(StandingsRepositoryError.realmError(.DataEmpty)))
      } else if let latestData = data.first {
        let currentDate = Date()
        let interval = currentDate.timeIntervalSince(latestData.update)
        
        if interval > 3600 {
          single(.failure(StandingsRepositoryError.realmError(.outdatedData)))
        } else {
          single(.success(latestData.standings))
        }
      }
      
      return Disposables.create()
    }
  }
  
  private func fetchFromAPI(season: Int, id: Int) -> Single<APIResponseStandings> {
    return apiManager.request(.standings(season: season, id: id))
  }
  
  private func saveToDB(response: APIResponseStandings) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self,
            let realm else {
        completable(.error(StandingsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      
      let standingsTable = standingsTableFromAPIResponseStandings(standingsResponse: response)
      
      do {
        try realm.write {
          realm.add(standingsTable, update: .modified)
          completable(.completed)
        }
      } catch {
        completable(.error(StandingsRepositoryError.realmError(.writeFailed)))
      }
      
      return Disposables.create()
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
