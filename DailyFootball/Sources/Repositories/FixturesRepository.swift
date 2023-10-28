//
//  FixturesRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RealmSwift

final class FixturesRepository {
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
  
  func fetchData(date: Date, season: Int, ids: [Int], timezone: String, status: String? = nil, completion: @escaping (Result<[FixtureTable], FixturesRepositoryError>) -> ()) {
    fetchFromDB(date: date, season: season, ids: ids) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        completion(.success(response))
      case .failure:
        self.fetchFromAPIAndSave(date: date, season: season, ids: ids, status: status, completion: completion)
      }
    }
  }
  
  private func fetchFromDB(date: Date, season: Int, ids: [Int], completion: @escaping (Result<[FixtureTable], FixturesRepositoryError>) -> ()) {
    guard let realm = self.realm else {
      completion(.failure(.realmError(.initializedFailed)))
      return
    }
    
    let dispatchGroup = DispatchGroup()
    var retrievedTables: [FixtureTable] = []
    var outdatedIDs: [Int] = []
    
    for id in ids {
      dispatchGroup.enter()
      
      let data = realm.objects(FixtureTable.self).filter("competitionId == \(id) AND date == %@ AND season == %@", date, "\(season)")
      
      if let retrievedData = data.first {
        let currentDate = Date()
        let interval = currentDate.timeIntervalSince(retrievedData.update)
        
        if interval <= 3600 {
          retrievedTables.append(retrievedData)
          dispatchGroup.leave()
        } else {
          // 데이터가 오래됐을 경우
          outdatedIDs.append(id)
          dispatchGroup.leave()
        }
      } else {
        // 데이터가 없는 경우
        outdatedIDs.append(id)
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      if !outdatedIDs.isEmpty {
        self.fetchFromAPIAndSave(date: date, season: season, ids: outdatedIDs, status: nil) { apiResult in
          switch apiResult {
          case .success(let freshFixtures):
            retrievedTables.append(contentsOf: freshFixtures)
            completion(.success(retrievedTables))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      } else {
        completion(.success(retrievedTables))
      }
    }
  }
  
  
  private func saveToDB(response: APIResponseFixtures) throws {
    guard let realm = self.realm else {
      throw FixturesRepositoryError.realmError(.initializedFailed)
    }
    let fixtureTable = mapFixtureTable(apiResponse: response)
    do {
      try realm.write {
        realm.add(fixtureTable, update: .modified)
      }
    } catch {
      throw FixturesRepositoryError.realmError(.writeFailed)
    }
  }
  
  private func fetchFromAPIAndSave(date: Date, season: Int, ids: [Int], status: String?, completion: @escaping (Result<[FixtureTable], FixturesRepositoryError>) -> ()) {
    let timezone = TimeZone.current.identifier
    let date = date.toString(format: .YYYYMMdd(separator: "-"))
    let dispatchGroup = DispatchGroup()
    var combinedFixtures: [FixtureTable] = []
    
    for id in ids {
      dispatchGroup.enter()
      apiManager.request(.fixtures(date: date, season: season, id: id, timezone: timezone, status: status)) { [weak self] (result: Result<APIResponseFixtures, APIFootballError>) in
        guard let self else { return }
        switch result {
        case .success(let response):
          do {
            try self.saveToDB(response: response)
            let fixtureTable = self.mapFixtureTable(apiResponse: response)
            combinedFixtures.append(fixtureTable)
            dispatchGroup.leave()
          } catch {
            completion(.failure(.realmError(.writeFailed)))
            dispatchGroup.leave()
          }
        case .failure(let apiError):
          completion(.failure(.apiError(apiError)))
          dispatchGroup.leave()
        }
      }
    }
    
    // 모든 병렬 작업이 완료될 때까지 대기
    dispatchGroup.notify(queue: .main) {
      completion(.success(combinedFixtures))
    }
  }
}

extension FixturesRepository {
  enum FixturesRepositoryError: Error {
    case realmError(RealmError)
    case apiError(APIFootballError)
    case unknownError
  }
}

extension FixturesRepository {
  private func mapFixtureTable(apiResponse: APIResponseFixtures) -> FixtureTable {
    let fixtureTable = FixtureTable()
    
    fixtureTable.competitionId = Int(apiResponse.parameters.league) ?? 0
    fixtureTable.season = apiResponse.parameters.season
    if let info = realm?.object(ofType: CompetitionInfoTable.self, forPrimaryKey: fixtureTable.competitionId) {
      fixtureTable.info = info
    }
    if let date = Date.fromString(apiResponse.parameters.date, format: .YYYYMMdd(separator: "-")) {
      fixtureTable.date = date
    }
    fixtureTable.update = Date()
    if let country = apiResponse.response.first?.league.country,
       let flag = apiResponse.response.first?.league.flag {
      fixtureTable.country = CountryTable(name: country, flag: flag)
    }
    
    for response in apiResponse.response {
      let fixtureData = mapResponseToFixtureData(response: response)
      fixtureTable.fixtureData.append(fixtureData)
    }
    
    return fixtureTable
  }
  
  private func mapResponseToFixtureData(response: APIResponseFixtures.Response) -> FixtureDataTable {
    let fixtureData = FixtureDataTable()
    fixtureData.round = response.league.round
    fixtureData.fixtureId = response.fixture.id
    fixtureData.referee = response.fixture.referee
    fixtureData.timezone = response.fixture.timezone
    fixtureData.timestamp = response.fixture.timestamp
    fixtureData.periods = mapPeriodsToPeriodsTable(periods: response.fixture.periods)
    fixtureData.venue = mapVenueToVenueTable(venue: response.fixture.venue)
    fixtureData.status = mapStatusToStatusTable(status: response.fixture.status)
    fixtureData.teams = mapTeamsToTeamsTable(teams: response.teams)
    fixtureData.goals = mapGoalsToHomeAwayGoalsTable(goals: response.goals)
    fixtureData.score = mapScoreToScoreTable(score: response.score)
    
    return fixtureData
  }
  
  private func mapPeriodsToPeriodsTable(periods: APIResponseFixtures.Periods) -> PeriodsTable {
    let periodsTable = PeriodsTable()
    periodsTable.first = periods.first
    periodsTable.second = periods.second
    return periodsTable
  }
  
  private func mapStatusToStatusTable(status: APIResponseFixtures.Status) -> StatusTable {
    let statusTable = StatusTable()
    statusTable.long = status.long
    statusTable.short = status.short
    statusTable.elapsed = status.elapsed
    return statusTable
  }
  
  private func mapTeamsToTeamsTable(teams: APIResponseFixtures.Teams) -> TeamsTable {
    let teamsTable = TeamsTable()
    teamsTable.home = mapAwayToTeamTable(team: teams.home)
    teamsTable.away = mapAwayToTeamTable(team: teams.away)
    return teamsTable
  }
  
  private func mapAwayToTeamTable(team: APIResponseFixtures.Team?) -> TeamTable? {
    guard let team = team else { return nil }
    let teamTable = TeamTable()
    teamTable.id = team.id
    teamTable.name = team.name
    teamTable.logo = team.logo
    return teamTable
  }
  
  private func mapGoalsToHomeAwayGoalsTable(goals: APIResponseFixtures.Goals) -> homeAwayGoalsTable {
    let goalsTable = homeAwayGoalsTable()
    goalsTable.home = goals.home
    goalsTable.away = goals.away
    return goalsTable
  }
  
  private func mapScoreToScoreTable(score: APIResponseFixtures.Score) -> ScoreTable {
    let scoreTable = ScoreTable()
    scoreTable.halftime = mapGoalsToHomeAwayGoalsTable(goals: score.halftime)
    scoreTable.fulltime = mapGoalsToHomeAwayGoalsTable(goals: score.fulltime)
    scoreTable.extratime = mapGoalsToHomeAwayGoalsTable(goals: score.extratime)
    scoreTable.penalty = mapGoalsToHomeAwayGoalsTable(goals: score.penalty)
    return scoreTable
  }
  
  private func mapVenueToVenueTable(venue: APIResponseFixtures.Venue) -> VenueTable {
    let venueTable = VenueTable()
    venueTable.id = venue.id
    venueTable.name = venue.name
    venueTable.city = venue.city
    return venueTable
  }
}
