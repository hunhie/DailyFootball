//
//  CompetitionGroupsRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift
import RxSwift

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
  
  deinit {
    print("컴페티션 레포 소멸")
  }
  
  private lazy var apiManager: APIFootballManager = {
    return APIFootballManager()
  }()
  
  func fetch() -> Single<Results<CompetitionTable>> {
    return fetchFromDB()
      .catch { [weak self] error -> Single<Results<CompetitionTable>> in
        guard let self else { return Single.error(error)}
        if let error = error as? CompetitionGroupsRepositoryError,
           case .realmError(let realmError) = error,
           realmError == .DataEmpty {
          return fetchFromAPI()
            .flatMapCompletable((saveToDB))
            .andThen(fetchFromDB())
        } else {
          return Single.error(error)
        }
      }
  }
  
  func fetchFromDB() -> Single<Results<CompetitionTable>> {
    return Single.create { [weak self] single in
      guard let self = self, let realm = self.realm else {
        single(.failure(CompetitionGroupsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      
      let data = realm.objects(CompetitionTable.self)
      if data.isEmpty {
        single(.failure(CompetitionGroupsRepositoryError.realmError(.DataEmpty)))
      } else {
        single(.success(data))
      }
      
      return Disposables.create()
    }
  }
  
  func fetchFromAPI() -> Single<APIResponseLeagues> {
    return apiManager.request(.leagues)
  }
  
  private func saveToDB(response: APIResponseLeagues) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self,
            let realm else {
        completable(.error(CompetitionGroupsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      
      let competitionTables = leagueTableFromAPIResponseLeagues(leaguesResponse: response)
      
      do {
        try realm.write {
          realm.add(competitionTables, update: .modified)
          completable(.completed)
        }
      } catch {
        completable(.error(CompetitionGroupsRepositoryError.realmError(.writeFailed)))
      }
      
      return Disposables.create()
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
