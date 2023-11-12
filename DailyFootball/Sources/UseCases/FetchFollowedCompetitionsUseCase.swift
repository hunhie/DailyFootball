//
//  FetchFollowedCompetitionsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/12.
//

import Foundation
import RxSwift

struct FetchFollowedCompetitionsUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  private let disposeBag = DisposeBag()
  
  func execute() -> Single<[Competition]> {
    return userCompetitionFollowsRepo.fetchFollowedCompetitions()
      .flatMap { value -> Single<[Competition]> in
        guard !value.isEmpty else {
          return .just([])
        }
        do {
          let data = try CompetitionMapper.mapCompetitions(from: value)
          return .just(data)
        } catch {
          return .error(FetchFollowedCompetitionsError.dataLoadFailed)
        }
      }
  }
}

extension FetchFollowedCompetitionsUseCase {
  enum FetchFollowedCompetitionsError: Error {
    case dataLoadFailed
    case dataEmpty
  }
}
