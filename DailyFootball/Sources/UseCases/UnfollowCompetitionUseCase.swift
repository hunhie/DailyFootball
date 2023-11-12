//
//  UnfollowCompetitionUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/09.
//

import Foundation
import RxSwift

struct UnfollowCompetitionUseCase {
  private let userCompetitionsFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute(competition: Competition) -> Completable {
    return userCompetitionsFollowsRepo.unfollowCompetition(competition: competition)
  }
}

extension UnfollowCompetitionUseCase {
  enum UnfollowCompetitionError: Error {
    case unfollowFailed
  }
}
