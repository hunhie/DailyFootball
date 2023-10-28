//
//  FetchFixturesByFollowedCompetitionUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

struct FetchFixturesByFollowedCompetitionUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  private let fixturesRepo = FixturesRepository()
  
  func execute(data: Date, season: Int, timezone: String, status: String? = nil, completion: @escaping (Result<[Fixtures], FetchFixturesByFollowedCompetitionError)) {
    
  }
}

extension FetchFixturesByFollowedCompetitionUseCase {
  enum FetchFixturesByFollowedCompetitionError {
    case nofollowedCompetition
    case dataEmpty
    case dataLoadFailed
  }
}
