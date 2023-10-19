//
//  FollowCompetitionUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/09.
//

import Foundation

struct FollowCompetitionUseCase {
  private let userCompetitionsFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute(competition: Competition) throws {
    do {
     try userCompetitionsFollowsRepo.followCompetition(competition: competition)
    } catch {
      throw FollowCompetitionError.followFailed
    }
  }
}

extension FollowCompetitionUseCase {
  enum FollowCompetitionError: Error {
    case followFailed
  }
}
