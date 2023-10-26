//
//  UserCompetitionFollowsRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/09.
//

import Foundation
import RealmSwift

final class UserCompetitionFollowsRepository {
  
  private var realm: Realm? {
    do {
      let realm = try Realm()
      return realm
    } catch {
      print("Error initializing realm: \(error)")
      return nil
    }
  }
  
  func fetchFollowedCompetitions(completion: @escaping (Result<Results<FollowedCompetitionTable>, UserCompetitionFollowsRepositoryError>) -> ()) {
    guard let realm else {
      completion(.failure(.realmError(.initializedFailed)))
      return
    }
    let data = realm.objects(FollowedCompetitionTable.self)
    completion(.success(data))
  }
  
  func followCompetition(competition: Competition) throws {
    guard let realm = self.realm else {
      throw UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)
    }
    
    if let originalCompetition = realm.object(ofType: CompetitionTable.self, forPrimaryKey: competition.id) {
      
      let followedCompetition = FollowedCompetitionTable() // FollowCompetitionTable 객체 생성
      followedCompetition.id = competition.id
      followedCompetition.logoURL = competition.logoURL
      followedCompetition.country = competition.country
      followedCompetition.title = competition.title
      followedCompetition.type = competition.type
      
      let seasons = List<SeasonTable>()
      originalCompetition.seasons.forEach { existingSeason in
        let newSeason = SeasonTable()
        newSeason.year = existingSeason.year
        newSeason.start = existingSeason.start
        newSeason.end = existingSeason.end
        newSeason.current = existingSeason.current
        
        // CoverageTable 복사
        if let originalCoverage = existingSeason.coverage {
          let newCoverage = CoverageTable()
          newCoverage.standings = originalCoverage.standings
          newCoverage.players = originalCoverage.players
          newCoverage.topScorers = originalCoverage.topScorers
          newCoverage.topAssists = originalCoverage.topAssists
          newCoverage.topCards = originalCoverage.topCards
          newCoverage.injuries = originalCoverage.injuries
          newCoverage.predictions = originalCoverage.predictions
          newCoverage.odds = originalCoverage.odds
          
          // FixturesTable 복사
          if let originalFixtures = originalCoverage.fixtures {
            let newFixtures = FixturesTable()
            newFixtures.events = originalFixtures.events
            newFixtures.lineups = originalFixtures.lineups
            newFixtures.statisticsFixtures = originalFixtures.statisticsFixtures
            newFixtures.statisticsPlayers = originalFixtures.statisticsPlayers
            newCoverage.fixtures = newFixtures
          }
          
          newSeason.coverage = newCoverage
        }
        
        seasons.append(newSeason)
      }
      
      followedCompetition.seasons = seasons // FollowCompetitionTable에 seasons 할당
      
      do {
        try realm.write {
          realm.add(followedCompetition) // FollowCompetitionTable 객체 저장
        }
      } catch {
        throw UserCompetitionFollowsRepositoryError.realmError(.writeFailed)
      }
    } else {
      throw UserCompetitionFollowsRepositoryError.realmError(.writeFailed)
    }
  }
  
  
  
  func unfollowCompetition(competition: Competition) throws {
    guard let realm else {
      throw UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)
    }
    
    if let competitionTable = realm.object(ofType: FollowedCompetitionTable.self, forPrimaryKey: competition.id) {
      do {
        try realm.write {
          realm.delete(competitionTable)
        }
      } catch {
        throw UserCompetitionFollowsRepositoryError.realmError(.writeFailed)
      }
    }
  }
  
  func reorderFollowedCompetitions(competitions: [Competition]) throws {
    guard let realm = self.realm else {
      throw UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)
    }
    
    do {
      try realm.write {
        let existingFollowedCompetitions = realm.objects(FollowedCompetitionTable.self)
        realm.delete(existingFollowedCompetitions)
        
        for competition in competitions {
          // 기존 CompetitionTable에서 해당하는 season 정보를 찾아옵니다.
          if let originalCompetition = realm.object(ofType: CompetitionTable.self, forPrimaryKey: competition.id) {
            
            let seasons = List<SeasonTable>()
            originalCompetition.seasons.forEach { existingSeason in
              let newSeason = SeasonTable()
              newSeason.year = existingSeason.year
              newSeason.start = existingSeason.start
              newSeason.end = existingSeason.end
              newSeason.current = existingSeason.current
              
              // CoverageTable 복사
              if let originalCoverage = existingSeason.coverage {
                let newCoverage = CoverageTable()
                newCoverage.standings = originalCoverage.standings
                newCoverage.players = originalCoverage.players
                newCoverage.topScorers = originalCoverage.topScorers
                newCoverage.topAssists = originalCoverage.topAssists
                newCoverage.topCards = originalCoverage.topCards
                newCoverage.injuries = originalCoverage.injuries
                newCoverage.predictions = originalCoverage.predictions
                newCoverage.odds = originalCoverage.odds
                
                // FixturesTable 복사
                if let originalFixtures = originalCoverage.fixtures {
                  let newFixtures = FixturesTable()
                  newFixtures.events = originalFixtures.events
                  newFixtures.lineups = originalFixtures.lineups
                  newFixtures.statisticsFixtures = originalFixtures.statisticsFixtures
                  newFixtures.statisticsPlayers = originalFixtures.statisticsPlayers
                  newCoverage.fixtures = newFixtures
                }
                
                newSeason.coverage = newCoverage
              }
              
              seasons.append(newSeason)
            }
            
            let followedCompetition = FollowedCompetitionTable(
              id: competition.id,
              title: competition.title,
              logoURL: competition.logoURL,
              type: competition.type,
              country: competition.country,
              seasons: seasons
            )
            
            realm.add(followedCompetition, update: .all)
          } else {
            throw UserCompetitionFollowsRepositoryError.realmError(.writeFailed)
          }
        }
      }
    } catch {
      throw UserCompetitionFollowsRepositoryError.realmError(.writeFailed)
    }
  }
  
  
  func isCompetitionFollowed(competition: Competition) -> Bool {
    guard let realm else { return false }
    
    let predicate = NSPredicate(format: "id == %@", competition.id)
    let result = realm.objects(FollowedCompetitionTable.self).filter(predicate)
    
    return !result.isEmpty
  }
}

extension UserCompetitionFollowsRepository {
  enum UserCompetitionFollowsRepositoryError: Error {
    case realmError(RealmError)
  }
}
