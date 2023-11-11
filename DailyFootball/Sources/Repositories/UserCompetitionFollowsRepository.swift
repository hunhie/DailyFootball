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
      print(realm.configuration.fileURL)
      return realm
    } catch {
      print("Error initializing realm: \(error)")
      return nil
    }
  }
  
  deinit {
    print("유저 팔로우 레포지토리 소멸")
  }
  
  func fetchFollowedCompetitions() -> Single<Results<FollowedCompetitionTable>> {
    return Single.create { [weak self] single in
      guard let self,
            let realm else {
        single(.failure(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      
      let data = realm.objects(FollowedCompetitionTable.self)
      single(.success(data))
      
      return Disposables.create()
    }
  }
  
  func followCompetition(competition: Competition) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self,
            let realm else {
        completable(.error(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      
      if let originalCompetitionTable = realm.object(ofType: CompetitionTable.self, forPrimaryKey: competition.id) {
        
        let followedCompetitionTable = self.mapFollowedCompetitionTableWithCompetitionTable(with: originalCompetitionTable)
        
        do {
          try realm.write {
            realm.add(followedCompetitionTable, update: .modified) // FollowCompetitionTable 객체 저장
          }
          completable(.completed)
        } catch {
          print("팔로우 쓰기 실패")
          completable(.error(UserCompetitionFollowsRepositoryError.realmError(.writeFailed)))
        }
      } else {
        completable(.error(UserCompetitionFollowsRepositoryError.realmError(.DataEmpty)))
        print("팔로우할 아이템 없음")
      }
      return Disposables.create()
    }
  }
  
  func unfollowCompetition(competition: Competition) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self,
            let realm else {
        completable(.error(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
      }
      
      if let competitionTable = realm.object(ofType: FollowedCompetitionTable.self, forPrimaryKey: competition.id) {
        do {
          try realm.write {
            realm.delete(competitionTable)
          }
          completable(.completed)
        } catch {
          print("언팔로우 쓰기 실패")
          completable(.error(UserCompetitionFollowsRepositoryError.realmError(.writeFailed)))
        }
      } else {
        print("언팔로우할 아이템 없음")
        completable(.error(UserCompetitionFollowsRepositoryError.realmError(.DataEmpty)))
      }
      return Disposables.create()
    }
  }
  
  func reorderFollowedCompetitions(competitions: [Competition]) -> Completable {
    return Completable.create { [weak self] completable in
      guard let self,
            let realm else {
        completable(.error(UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)))
        return Disposables.create()
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
              completable(.completed)
            } else {
              completable(.error(UserCompetitionFollowsRepositoryError.realmError(.DataEmpty)))
            }
          }
        }
      } catch {
        completable(.error(UserCompetitionFollowsRepositoryError.realmError(.writeFailed)))
      }
      
      return Disposables.create()
    }
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
