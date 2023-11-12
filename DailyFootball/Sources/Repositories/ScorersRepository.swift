//
//  TopScorersRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift
import RxSwift

final class ScorersRepository {
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
  
  func fetch(season: Int, id: Int) -> Single<LeagueTopScorersTable> {
    return fetchFromDB(season: season, id: id)
      .catch { [weak self] error -> Single<LeagueTopScorersTable> in
        guard let self else { return Single.error(error) }
        if let error = error as? TopScorersRepositoryError {
          return fetchFromAPI(season: season, id: id)
            .flatMapCompletable((saveToDB))
            .andThen(fetchFromDB(season: season, id: id))
        } else {
          return Single.error(error)
        }
      }
  }
  
  private func fetchFromAPI(season: Int, id: Int) -> Single<APIResponseTopscorers> {
    return apiManager.request(.topScorers(season: season, id: id))
  }
  
  private func fetchFromDB(season: Int, id: Int) -> Single<LeagueTopScorersTable> {
    return Single.create { [weak self] single in
      guard let self,
            let realm else {
        single(.failure(TopScorersRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      let data = realm.objects(LeagueTopScorersTable.self).filter("id == '\(id)' AND season == '\(season)'")
      
      if let retievedData = data.first {
        let currentDate = Date()
        let interval = currentDate.timeIntervalSince(retievedData.update)
        if interval > 3600 {
          single(.failure(TopScorersRepositoryError.realmError(.outdatedData)))
        } else {
          single(.success(retievedData))
        }
      } else {
        single(.failure(TopScorersRepositoryError.realmError(.DataEmpty)))
      }
      
      return Disposables.create()
    }
  }
  
  private func saveToDB(response: APIResponseTopscorers) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self,
            let realm else {
        completable(.error(TopScorersRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      let topScorersTable = mapTopScorersTable(from: response)
      do {
        try realm.write {
          realm.add(topScorersTable, update: .modified)
          completable(.completed)
        }
      } catch {
        completable(.error(TopScorersRepositoryError.realmError(.writeFailed)))
      }
      return Disposables.create()
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
