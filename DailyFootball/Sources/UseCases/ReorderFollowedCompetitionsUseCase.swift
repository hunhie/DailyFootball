//
//  ReorderFollowedCompetitionsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/19.
//

import Foundation

struct ReorderFollowedCompetitionsUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute(with reorderedFollowedCompetitions: [Competition]) throws {
    do {
      try userCompetitionFollowsRepo.reorderFollowedCompetitions(competitions: reorderedFollowedCompetitions)
    } catch {
      throw ReorderFollowedCompetitionsError.reorderFailed
    }
  }
}

extension ReorderFollowedCompetitionsUseCase {
  enum ReorderFollowedCompetitionsError: Error {
    case reorderFailed
  }
}
