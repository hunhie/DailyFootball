//
//  FollowCompetitionUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/09.
//

import Foundation
import RxSwift

struct FollowCompetitionUseCase {
  private let userCompetitionsFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute(competition: Competition) -> Completable {
    return userCompetitionsFollowsRepo.followCompetition(competition: competition)
  }
}

extension FollowCompetitionUseCase {
  enum FollowCompetitionError: Error {
    case followFailed
  }
}
