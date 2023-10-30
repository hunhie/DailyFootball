//
//  FetchFixturesByFollowedCompetitionUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

struct FetchFixturesByFollowedCompetitionUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  private let fixturesRepo = FixturesDataRepository()
  
  func execute(date: Date, status: String? = nil, completion: @escaping (Result<[FixtureGroupByCompetition], FetchFixturesByFollowedCompetitionError>) -> ()) {
    
    userCompetitionFollowsRepo.fetchFollowedCompetitions { result in
      switch result {
      case .success(let response):
        if response.isEmpty {
          completion(.failure(.noFollowCompetition))
        } else {
          do {
            let followCompetitions = try CompetitionMapper.mapCompetitions(from: response)
            let targetSeasonAndId = followCompetitions.map { competition in
              let currentSeason: [Competition.Season] = competition.season.filter{ $0.current == true }
              let currentSeasonYear = currentSeason[0].year
              return (id: competition.id, season: currentSeasonYear)
            }
            
            fixturesRepo.fetchData(date: date, targetCompetitions: targetSeasonAndId) { result in
              switch result {
              case .success(let response):
                do {
                  var fixtureGroups: [FixtureGroupByCompetition] = []
                  for table in response {
                    let fixtureGroup = try FixtureGroupMapper.mapEntity(from: table)
                    fixtureGroups.append(fixtureGroup)
                  }
                  
                  let orderDict = Dictionary(uniqueKeysWithValues: followCompetitions.enumerated().map { ($1.id, $0) })

                  let groupsWithFixtures = fixtureGroups.filter { !$0.fixtures.isEmpty }
                  let groupsWithoutFixtures = fixtureGroups.filter { $0.fixtures.isEmpty }

                  let sortedGroupsWithFixtures = groupsWithFixtures.sorted { orderDict[$0.info.id]! < orderDict[$1.info.id]! }
                  let sortedGroupsWithoutFixtures = groupsWithoutFixtures.sorted { orderDict[$0.info.id]! < orderDict[$1.info.id]! }

                  let sortedFixtureGroups = sortedGroupsWithFixtures + sortedGroupsWithoutFixtures
                  completion(.success(sortedFixtureGroups))
                } catch {
                  completion(.failure(.dataLoadFailed))
                }
              case .failure:
                completion(.failure(.dataLoadFailed))
              }
            }
          } catch {
            completion(.failure(.dataLoadFailed))
          }
        }
      case .failure:
        completion(.failure(.dataLoadFailed))
      }
    }
  }
}

extension FetchFixturesByFollowedCompetitionUseCase {
  enum FetchFixturesByFollowedCompetitionError: Error {
    case noFollowCompetition
    case dataLoadFailed
  }
}
