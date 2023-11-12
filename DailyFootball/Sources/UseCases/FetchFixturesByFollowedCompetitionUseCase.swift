//
//  FetchFixturesByFollowedCompetitionUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RxSwift

struct FetchFixturesByFollowedCompetitionUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  private let fixturesRepo = FixturesDataRepository()
  
  func execute(date: Date, status: String? = nil) -> Single<[FixtureGroupByCompetition]> {
    return userCompetitionFollowsRepo.fetchFollowedCompetitions()
      .flatMap { competitions -> Single<[FixtureGroupByCompetition]> in
        if competitions.isEmpty {
          return .just([])
        } else {
          do {
            let followCompetitions = try CompetitionMapper.mapCompetitions(from: competitions)
            let targetSeasonAndId = followCompetitions.map { competition in
              let currentSeason: [Competition.Season] = competition.season.filter{ $0.current == true }
              let currentSeasonYear = currentSeason[0].year
              return (id: competition.id, season: currentSeasonYear)
            }
            
            return self.fixturesRepo.fetch(date: date, targetCompetitions: targetSeasonAndId, status: status)
              .flatMap { result -> Single<[FixtureGroupByCompetition]> in
                do {
                  var fixtureGroups: [FixtureGroupByCompetition] = []
                  for table in result {
                    let fixtureGroup = try FixtureGroupMapper.mapEntity(from: table)
                    fixtureGroups.append(fixtureGroup)
                  }
                  
                  let orderDict = Dictionary(uniqueKeysWithValues: followCompetitions.enumerated().map { ($1.id, $0) })
                  
                  let groupsWithFixtures = fixtureGroups.filter { !$0.fixtures.isEmpty }
                  let groupsWithoutFixtures = fixtureGroups.filter { $0.fixtures.isEmpty }
                  
                  let sortedGroupsWithFixtures = groupsWithFixtures.sorted { orderDict[$0.info.id]! < orderDict[$1.info.id]! }
                  let sortedGroupsWithoutFixtures = groupsWithoutFixtures.sorted { orderDict[$0.info.id]! < orderDict[$1.info.id]! }
                  
                  return .just(sortedGroupsWithFixtures + sortedGroupsWithoutFixtures)
                } catch {
                  return .error(FetchFixturesByFollowedCompetitionError.dataLoadFailed)
                }
              }
          } catch {
            return .error(FetchFixturesByFollowedCompetitionError.dataLoadFailed)
          }
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
