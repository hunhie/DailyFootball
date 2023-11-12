//
//  FetchAllCompetitionGroupedByCountryUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import Foundation
import RxSwift

struct FetchAllCompetitionGroupedByCountryUseCase {
  private let competitionGroupRepo = CompetitionGroupsRepository()
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute() -> Single<[CompetitionGroupByCountry]> {
    let competitionGroupsSingle = competitionGroupRepo.fetch()
    let followedCompetitionsSingle = userCompetitionFollowsRepo.fetchFollowedCompetitions()
    
    return Single.zip(competitionGroupsSingle, followedCompetitionsSingle)
      .flatMap { competitionGroups, followedCompetitions in
        do {
          let data = try CompetitionGroupMapper.mapCompetitionGroups(from: competitionGroups, followedCompetitions: followedCompetitions)
          let userCountryCode = Locale.current.language.region?.identifier ?? ""
          
          let sortedData = data.sorted {
            if $0.country.code == userCountryCode { return true }
            if $1.country.code == userCountryCode { return false }
            if $0.country.name == "World" { return true }
            if $1.country.name == "World" { return false }
            return $0.country.name < $1.country.name
          }
          
          return Single.just(sortedData)
        } catch {
          return Single.error(FetchAllCompetitionGroupedByCountryError.noDataAvailable)
        }
      }
  }
}

extension FetchAllCompetitionGroupedByCountryUseCase {
  enum FetchAllCompetitionGroupedByCountryError: Error {
    case dataLoadFailed
    case noDataAvailable
    case unknownError
  }
}
