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
    guard let realm else {
      throw UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)
    }
    
    let competitionTable = FollowedCompetitionTable(id: competition.id, title: competition.title, logoURL: competition.logoURL, type: competition.type, country: competition.country)
    
    do {
      try realm.write {
        realm.add(competitionTable, update: .modified)
      }
    } catch {
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
    guard let realm else {
      throw UserCompetitionFollowsRepositoryError.realmError(.initializedFailed)
    }
    
    do {
      try realm.write {
        let existingFollowedCompetitions = realm.objects(FollowedCompetitionTable.self)
        realm.delete(existingFollowedCompetitions)
        
        for competition in competitions {
          let followedCompetition = FollowedCompetitionTable(
            id: competition.id,
            title: competition.title,
            logoURL: competition.logoURL,
            type: competition.type,
            country: competition.country
          )
          
          realm.add(followedCompetition, update: .all)
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
