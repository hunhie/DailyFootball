//
//  FetchLeagueScorersUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

struct FetchLeagueScorersUseCase {
  private let scorersRepo = ScorersRepository()
  
  func execute(season: Int, id: Int, completion: @escaping (Result<[Scorer], FetchLeagueScorersError>) -> ()) {
    
    scorersRepo.fetchData(season: season, id: id) { result in
      switch result {
      case .success(let response):
        let data = ScorersMapper.toEntity(from: response)
        completion(.success(data))
      case .failure(let error):
        completion(.failure(.fetchFailed))
      }
    }
  }
}

extension FetchLeagueScorersUseCase {
  enum FetchLeagueScorersError: Error {
    case fetchFailed
  }
}
