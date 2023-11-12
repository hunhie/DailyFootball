//
//  FetchLeagueStandingsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/25.
//

import Foundation
import RxSwift

struct FetchLeagueStandingsUseCase {
  private let standingsRepo = StandingsRepository()

  func execute(season: Int, id: Int) -> Single<[Standing]> {
    return standingsRepo.fetch(season: season, id: id)
      .flatMap { value -> Single<[Standing]> in
        return .just(StandingMapper.mapStandings(from: value))
      }
  }
}

extension FetchLeagueStandingsUseCase {
  enum FetchLeagueStandingsError: Error {
    case fetchFailed
  }
}

