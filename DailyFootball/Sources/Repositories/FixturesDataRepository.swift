//
//  FixturesDataRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RealmSwift

final class FixturesDataRepository {
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
  
  func fetchData(date: Date, targetCompetitions: [(id: Int, season: Int)], status: String? = nil, completion: @escaping (Result<[CompetitionFixtureTable], FixturesRepositoryError>) -> ()) {
    fetchFromDB(date: date, targetCompetitions: targetCompetitions) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        completion(.success(response))
      case .failure:
        self.fetchFromAPIAndSave(date: date, targetCompetitions: targetCompetitions, status: status, completion: completion)
      }
    }
  }
  
  private func fetchFromDB(date: Date, targetCompetitions: [(id: Int, season: Int)], completion: @escaping (Result<[CompetitionFixtureTable], FixturesRepositoryError>) -> ()) {
    guard let realm = self.realm else {
      completion(.failure(.realmError(.initializedFailed)))
      return
    }
    
    let dispatchGroup = DispatchGroup()
    var retrievedTables: [CompetitionFixtureTable] = []
    var outdatedCompetitions: [(id: Int, season: Int)] = []
    
    for (id, season) in targetCompetitions {
      dispatchGroup.enter()
      
      do {
        let dateRange = try date.betweenDate()
        let data = realm.objects(CompetitionFixtureTable.self)
          .filter("competitionId == \(id) AND date BETWEEN %@", [dateRange.start, dateRange.end])
        
        if let retrievedData = data.first {
          let currentDate = Date()
          let interval = currentDate.timeIntervalSince(retrievedData.update)
          
          if interval <= 3600 {
            retrievedTables.append(retrievedData)
            dispatchGroup.leave()
          } else {
            // 데이터가 오래됐을 경우
            outdatedCompetitions.append((id, season))
            dispatchGroup.leave()
          }
        } else {
          // 데이터가 없는 경우
          outdatedCompetitions.append((id, season))
          dispatchGroup.leave()
        }
      } catch {
        print("An error occurred:", error)
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      if !outdatedCompetitions.isEmpty {
        self.fetchFromAPIAndSave(date: date, targetCompetitions: outdatedCompetitions, status: nil) { apiResult in
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
  
  private func fetchFromAPIAndSave(date: Date, targetCompetitions: [(id: Int, season: Int)], status: String?, completion: @escaping (Result<[CompetitionFixtureTable], FixturesRepositoryError>) -> ()) {
    let timezone = TimeZone.current.identifier
    let date = date.toString(format: .YYYYMMdd(separator: "-"))
    let dispatchGroup = DispatchGroup()
    var combinedFixtures: [CompetitionFixtureTable] = []
    dump(targetCompetitions)
    for (id, season) in targetCompetitions {
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

extension FixturesDataRepository {
  enum FixturesRepositoryError: Error {
    case realmError(RealmError)
    case apiError(APIFootballError)
    case unknownError
  }
}

extension FixturesDataRepository {
  private func mapCountryWithCompetitionPk(_ pk: Int) -> CountryTable? {
    guard let realm = self.realm else { return nil }
    let competition = realm.object(ofType: CompetitionTable.self, forPrimaryKey: pk)
    return competition?.country
  }
  
  private func mapFixtureTable(apiResponse: APIResponseFixtures) -> CompetitionFixtureTable {
    let fixtureTable = CompetitionFixtureTable()
    
    let competitionId = Int(apiResponse.parameters.league) ?? 0
    fixtureTable.competitionId = competitionId
    fixtureTable.season = apiResponse.parameters.season
    if let info = realm?.object(ofType: CompetitionInfoTable.self, forPrimaryKey: fixtureTable.competitionId) {
      fixtureTable.info = info
    }
    if let date = Date.fromString(apiResponse.parameters.date, format: .YYYYMMdd(separator: "-")) {
      fixtureTable.date = date
    }
    fixtureTable.update = Date()
    
    dump(apiResponse.response)

    if let country = apiResponse.response.first?.league.country,
       let flag = apiResponse.response.first?.league.flag {
      fixtureTable.country = CountryTable(name: country, flag: flag)
    } else {
      fixtureTable.country = mapCountryWithCompetitionPk(competitionId)
    }
    
    for response in apiResponse.response {
      let fixtureData = mapResponseToFixtureData(response: response)
      fixtureTable.fixtureData.append(fixtureData)
    }
    
    return fixtureTable
  }
  
  private func mapResponseToFixtureData(response: APIResponseFixtures.Response) -> FixtureDetailTable {
    let fixtureData = FixtureDetailTable()
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
  
  private func mapGoalsToHomeAwayGoalsTable(goals: APIResponseFixtures.Goals) -> HomeAwayGoalsTable {
    let goalsTable = HomeAwayGoalsTable()
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
