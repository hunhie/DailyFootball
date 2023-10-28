//
//  FetchLeagueStandingsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/25.
//

import Foundation

struct FetchLeagueStandingsUseCase {
  private let standingsRepo = StandingsRepository()

  func execute(season: Int, id: Int, completion: @escaping (Result<[Standing], FetchLeagueStandingsError>) -> ()) {
    
    standingsRepo.fetchData(season: season, id: id) { result in
      switch result {
      case .success(let response):
        let data = StandingMapper.mapStandings(from: response)
        completion(.success(data))
      case .failure:
        completion(.failure(.fetchFailed))
      }
    }
  }
}

extension FetchLeagueStandingsUseCase {
  enum FetchLeagueStandingsError: Error {
    case fetchFailed
  }
}

