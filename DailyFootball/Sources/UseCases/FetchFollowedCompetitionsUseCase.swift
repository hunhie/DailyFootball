//
//  FetchFollowedCompetitionsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/12.
//

import Foundation

struct FetchFollowedCompetitionsUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute(completion: @escaping (Result<[Competition], FetchFollowedCompetitionsError>) -> ()) {
    userCompetitionFollowsRepo.fetchFollowedCompetitions { result in
      switch result {
      case .success(let response):
        if response.isEmpty {
          completion(.success([]))
        } else {
          do {
            let data = try CompetitionMapper.mapCompetitions(from: response)
            completion(.success(data))
          } catch {
            completion(.failure(.dataLoadFailed))
          }
        }
      case .failure:
        completion(.failure(.dataLoadFailed))
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
