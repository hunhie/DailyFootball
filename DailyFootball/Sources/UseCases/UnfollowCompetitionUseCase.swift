//
//  UnfollowCompetitionUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/09.
//

import Foundation

struct UnfollowCompetitionUseCase {
  private let userCompetitionsFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute(competition: Competition) throws {
    do {
     try userCompetitionsFollowsRepo.unfollowCompetition(competition: competition)
    } catch {
      throw UnfollowCompetitionError.unfollowFailed
    }
  }
}

extension UnfollowCompetitionUseCase {
  enum UnfollowCompetitionError: Error {
    case unfollowFailed
  }
}
