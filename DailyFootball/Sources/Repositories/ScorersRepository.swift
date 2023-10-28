//
//  TopScorersRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

final class ScorersRepository {
  private var realm: Realm? {
    do {
      let realm = try Realm()
      print(realm.configuration.fileURL)
      return realm
    } catch {
      print("Error initializing realm: \(error)")
      return nil
    }
  }
  
  private lazy var apiManager: APIFootballManager = {
    return APIFootballManager()
  }()
  
  
  public func fetchData(season: Int, id: Int, completion: @escaping (Result<LeagueTopScorersTable, TopScorersRepositoryError>) -> ()) {
    fetchFromDB(season: season, id: id) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        completion(.success(response))
      case .failure:
        self.fetchFromAPIAndSave(season: season, id: id, completion: completion)
      }
    }
  }
  
  private func fetchFromDB(season: Int, id: Int, completion: @escaping (Result<LeagueTopScorersTable, TopScorersRepositoryError>) -> ()) {
    guard let realm = self.realm else {
      completion(.failure(.realmError(.initializedFailed)))
      return
    }
    let data = realm.objects(LeagueTopScorersTable.self).filter("id == '\(id)' AND season == '\(season)'")
    
    if let retievedData = data.first {
      let currentDate = Date()
      let interval = currentDate.timeIntervalSince(retievedData.update)
      if interval > 3600 {
        completion(.failure(.realmError(.outdatedData)))
      } else {
        completion(.success(retievedData))
      }
    } else {
      completion(.failure(.realmError(.DataEmpty)))
    }
  }
  
  private func saveToDB(response: APIResponseTopscorers) throws {
    guard let realm = self.realm else {
      throw TopScorersRepositoryError.realmError(.initializedFailed)
    }
    let topScorersTable = mapTopScorersTable(from: response)
    do {
      try realm.write {
        realm.add(topScorersTable, update: .modified)
      }
    } catch {
      throw TopScorersRepositoryError.realmError(.writeFailed)
    }
  }
  
  private func fetchFromAPIAndSave(season: Int, id: Int, completion: @escaping (Result<LeagueTopScorersTable, TopScorersRepositoryError>) -> ()) {
    apiManager.request(.topScorers(season: season, id: id)) { [weak self] (result: Result<APIResponseTopscorers, APIFootballError>) in
      switch result {
      case .success(let response):
        do {
          try self?.saveToDB(response: response)
          if let data = self?.realm?.object(ofType: LeagueTopScorersTable.self, forPrimaryKey: "\(id)") {
            completion(.success(data))
          } else {
            completion(.failure(.realmError(.DataEmpty)))
          }
        } catch let error as TopScorersRepositoryError {
          completion(.failure(error))
        } catch {
          completion(.failure(.unknownError))
        }
      case .failure(let apiError):
        completion(.failure(.apiError(apiError)))
      }
    }
  }
}

extension ScorersRepository {
  enum TopScorersRepositoryError: Error {
    case realmError(RealmError)
    case apiError(APIFootballError)
    case unknownError
  }
  
  // Player 매핑
  private func mapPlayer(from apiPlayer: APIResponseTopscorers.Player) -> PlayerTable {
    let player = PlayerTable()
    player.id = apiPlayer.id
    player.name = apiPlayer.name
    player.firstname = apiPlayer.firstname
    player.lastname = apiPlayer.lastname
    player.age = apiPlayer.age
    player.birthDate = apiPlayer.birth.date
    player.birthPlace = apiPlayer.birth.place
    player.birthCountry = apiPlayer.birth.country
    player.nationality = apiPlayer.nationality
    player.height = apiPlayer.height
    player.weight = apiPlayer.weight
    player.injured = apiPlayer.injured
    player.photo = apiPlayer.photo
    return player
  }
  
  // Team 매핑
  private func mapTeam(from apiTeam: APIResponseTopscorers.Team) -> TeamTable {
    let team = TeamTable()
    team.id = apiTeam.id
    team.name = apiTeam.name
    team.logo = apiTeam.logo
    return team
  }
  
  // Game 매핑
  private func mapGames(from apiGames: APIResponseTopscorers.Games) -> GameTable {
    let game = GameTable()
    game.appearences = apiGames.appearences
    game.lineups = apiGames.lineups
    game.minutes = apiGames.minutes
    return game
  }
  
  private func mapCards(from apiCards: APIResponseTopscorers.Cards) -> CardsTable {
    let cards = CardsTable()
    cards.red = apiCards.red
    cards.yellow = apiCards.yellow
    cards.yellowred = apiCards.yellowred
    return cards
  }
  
  private func mapDribbles(from apiDribbles: APIResponseTopscorers.Dribbles) -> DribblesTable {
    let dribbles = DribblesTable()
    dribbles.attempts = apiDribbles.attempts ?? 0
    dribbles.success = apiDribbles.success ?? 0
    return dribbles
  }
  
  private func mapDuels(from apiDuels: APIResponseTopscorers.Duels) -> DuelsTable {
    let duels = DuelsTable()
    duels.total = apiDuels.total ?? 0
    duels.won = apiDuels.won ?? 0
    return duels
  }
  
  private func mapFouls(from apiFouls: APIResponseTopscorers.Fouls) -> FoulsTable {
    let fouls = FoulsTable()
    fouls.committed = apiFouls.committed ?? 0
    fouls.drawn = apiFouls.drawn ?? 0
    return fouls
  }
  
  private func mapGoals(from apiGoals: APIResponseTopscorers.Goals) -> GoalsTable {
    let goals = GoalsTable()
    goals.assists = apiGoals.assists ?? 0
    goals.conceded = apiGoals.conceded ?? 0
    goals.total = apiGoals.total ?? 0
    return goals
  }
  
  private func mapPasses(from apiPasses: APIResponseTopscorers.Passes) -> PassesTable {
    let passes = PassesTable()
    passes.accuracy = apiPasses.accuracy ?? 0
    passes.key = apiPasses.key ?? 0
    passes.total = apiPasses.total ?? 0
    return passes
  }
  
  private func mapPenalty(from apiPenalty: APIResponseTopscorers.Penalty) -> PenaltyTable {
    let penalty = PenaltyTable()
    penalty.missed = apiPenalty.missed ?? 0
    penalty.scored = apiPenalty.scored ?? 0
    return penalty
  }
  
  private func mapShots(from apiShots: APIResponseTopscorers.Shots) -> ShotsTable {
    let shots = ShotsTable()
    shots.on = apiShots.on ?? 0
    shots.total = apiShots.total ?? 0
    return shots
  }
  
  private func mapSubstitues(from apiSubstitues: APIResponseTopscorers.Substitutes) -> SubstitutesTable {
    let substitues = SubstitutesTable()
    substitues.bench = apiSubstitues.bench ?? 0
    substitues.substitutesIn = apiSubstitues.substitutesIn ?? 0
    substitues.out = apiSubstitues.out ?? 0
    return substitues
  }
  
  private func mapTackles(from apiTackles: APIResponseTopscorers.Tackles) -> TacklesTable {
    let tackles = TacklesTable()
    tackles.blocks = apiTackles.blocks
    tackles.interceptions = apiTackles.interceptions
    tackles.total = apiTackles.total ?? 0
    return tackles
  }
  
  // Statistic 매핑
  private func mapStatistic(from apiStatistic: APIResponseTopscorers.Statistic) -> StatisticTable {
    
    let statistic = StatisticTable()
    statistic.team = mapTeam(from: apiStatistic.team)
    statistic.games = mapGames(from: apiStatistic.games)
    statistic.cards = mapCards(from: apiStatistic.cards)
    statistic.dribbles = mapDribbles(from: apiStatistic.dribbles)
    statistic.duels = mapDuels(from: apiStatistic.duels)
    statistic.fouls = mapFouls(from: apiStatistic.fouls)
    statistic.goals = mapGoals(from: apiStatistic.goals)
    statistic.passes = mapPasses(from: apiStatistic.passes)
    statistic.penalty = mapPenalty(from: apiStatistic.penalty)
    statistic.shots = mapShots(from: apiStatistic.shots)
    statistic.substitutes = mapSubstitues(from: apiStatistic.substitutes)
    statistic.tackles = mapTackles(from: apiStatistic.tackles)
    
    return statistic
  }
  
  // TopScorer 매핑
  private func mapTopScorer(from apiResponse: APIResponseTopscorers.Response) -> TopScorerTable {
    let topScorer = TopScorerTable()
    topScorer.player = mapPlayer(from: apiResponse.player)
    for apiStat in apiResponse.statistics {
      topScorer.statistics = mapStatistic(from: apiStat)
    }
    return topScorer
  }
  
  // LeagueTopScorersTable 매핑
  private func mapTopScorersTable(from apiTopscorers: APIResponseTopscorers) -> LeagueTopScorersTable {
    let topScorersTable = LeagueTopScorersTable()
    topScorersTable.id = apiTopscorers.parameters.league
    topScorersTable.season = apiTopscorers.parameters.season
    topScorersTable.update = Date()
    
    var lastScore: Int? = nil
    var currentRank = 1
    for (index, response) in apiTopscorers.response.enumerated() {
      let topScorer = mapTopScorer(from: response)
      
      if let lastScore = lastScore, topScorer.statistics?.goals?.total == lastScore {
      } else {
        currentRank = index + 1
      }
      
      topScorer.rank = currentRank
      lastScore = topScorer.statistics?.goals?.total
      
      topScorersTable.topScorers.append(topScorer)
    }
    
    return topScorersTable
  }
  
}
