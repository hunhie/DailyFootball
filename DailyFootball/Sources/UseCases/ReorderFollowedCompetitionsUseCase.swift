//
//  ReorderFollowedCompetitionsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/19.
//

import Foundation
import RxSwift

struct ReorderFollowedCompetitionsUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()

  func execute(with reorderedFollowedCompetitions: [Competition]) -> Completable {
    return userCompetitionFollowsRepo.reorderFollowedCompetitions(competitions: reorderedFollowedCompetitions)
  }
}

extension ReorderFollowedCompetitionsUseCase {
  enum ReorderFollowedCompetitionsError: Error {
    case reorderFailed
  }
}
