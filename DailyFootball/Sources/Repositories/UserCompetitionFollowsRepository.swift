//
//  UserCompetitionFollowsRepository.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/09.
//

import Foundation
import RealmSwift
import RxSwift

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
  
  func fetchFollowedCompetitions() -> PublishSubject<Results<FollowedCompetitionTable>> {
    let subject = PublishSubject<Results<FollowedCompetitionTable>>()
    
    guard let realm else {
      subject.onError(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed))
      return subject
    }
    
    let data = realm.objects(FollowedCompetitionTable.self)
    subject.onNext(data)
    
    return subject
  }
  
  func followCompetition(competition: Competition) -> PublishSubject<Void> {
    let subject = PublishSubject<Void>()
    guard let realm = self.realm else {
      subject.onError(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed))
      return subject
    }
    
    if let originalCompetitionTable = realm.object(ofType: CompetitionTable.self, forPrimaryKey: competition.id) {
      
      let followedCompetitionTable = self.mapFollowedCompetitionTableWithCompetitionTable(with: originalCompetitionTable)
      
      do {
        try realm.write {
          realm.add(followedCompetitionTable) // FollowCompetitionTable 객체 저장
        }
        subject.onCompleted()
      } catch {
        subject.onError(UserCompetitionFollowsRepositoryError.realmError(.writeFailed))
      }
    } else {
      subject.onError(UserCompetitionFollowsRepositoryError.realmError(.writeFailed))
    }
    return subject
  }
  
  func unfollowCompetition(competition: Competition) -> PublishSubject<Void> {
    let subject = PublishSubject<Void>()
    guard let realm = self.realm else {
      subject.onError(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed))
      return subject
    }
    
    if let competitionTable = realm.object(ofType: FollowedCompetitionTable.self, forPrimaryKey: competition.id) {
      do {
        try realm.write {
          realm.delete(competitionTable)
        }
        subject.onCompleted()
      } catch {
        subject.onError(UserCompetitionFollowsRepositoryError.realmError(.writeFailed))
      }
    }
    return subject
  }
  
  func reorderFollowedCompetitions(competitions: [Competition]) -> PublishSubject<Void> {
    let subject = PublishSubject<Void>()
    guard let realm = self.realm else {
      subject.onError(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed))
      return subject
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
                  let newFixtures = FixturesInfoTable()
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
              info: CompetitionInfoTable(id: competition.id, name: competition.info.name, type: competition.info.type, logoURL: competition.info.logoURL),
              country: CountryMapper.mapCountryTable(from: competition.country),
              seasons: seasons
            )
            
            realm.add(followedCompetition, update: .all)
            subject.onCompleted()
          } else {
            subject.onError(UserCompetitionFollowsRepositoryError.realmError(.writeFailed))
          }
        }
      }
    } catch {
      subject.onError(UserCompetitionFollowsRepositoryError.realmError(.writeFailed))
    }
    return subject
  }
  
  
  func isCompetitionFollowed(competition: Competition) -> BehaviorSubject<Bool> {
    let subject = BehaviorSubject<Bool>(value: false)
    guard let realm = self.realm else {
      subject.onError(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed))
      return subject
    }
    
    let predicate = NSPredicate(format: "id == %@", competition.id)
    let result = realm.objects(FollowedCompetitionTable.self).filter(predicate)
    subject.onNext(realm.isEmpty)
    
    return subject
  }
}

extension UserCompetitionFollowsRepository {
  enum UserCompetitionFollowsRepositoryError: Error {
    case realmError(RealmError)
  }
}

extension UserCompetitionFollowsRepository {
  private func mapFollowedCompetitionTableWithCompetitionTable(with table: CompetitionTable) -> FollowedCompetitionTable {
    return FollowedCompetitionTable(id: table.id, info: table.info, country: table.country, seasons: table.seasons)
  }
}
