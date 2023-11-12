//
//  FetchLeagueScorersUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RxSwift

struct FetchLeagueScorersUseCase {
  private let scorersRepo = ScorersRepository()
  
  func execute(season: Int, id: Int) -> Single<[Scorer]> {
    return scorersRepo.fetch(season: season, id: id)
      .flatMap { value -> Single<[Scorer]> in
        return .just(ScorersMapper.toEntity(from: value))
      }
  }
}

extension FetchLeagueScorersUseCase {
  enum FetchLeagueScorersError: Error {
    case fetchFailed
  }
}
