//
//  FetchAllCompetitionGroupedByCountryUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import Foundation

struct FetchAllCompetitionGroupedByCountryUseCase {
  private let competitionGroupRepo = CompetitionGroupsRepository()
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  
  func execute(completion: @escaping (Result<[CompetitionGroup], FetchAllCompetitionGroupedByCountryError>) -> ()) {
    competitionGroupRepo.fetchData { result in
      switch result {
      case .success(let response):
        userCompetitionFollowsRepo.fetchFollowedCompetitions { followResult in
          switch followResult {
          case .success(let followedCompetitions):
            let data = CompetitionGroupMapper.mapCompetitionGroups(from: response, followedCompetitions: followedCompetitions)
            completion(.success(data))
          case .failure(_): 
            completion(.failure(.dataLoadFailed))
          }
        }
      case .failure(let error):
        switch error {
        case .apiError(.serverError), .apiError(.decodingError), .apiError(.timeout), .unknownError, .realmError(.initializedFailed), .realmError(.writeFailed):
          completion(.failure(.dataLoadFailed))
        case .apiError(.noData), .realmError(.DataEmpty), .realmError(.outdatedData):
          completion(.failure(.noDataAvailable))
        case .apiError(.unknownError):
          completion(.failure(.unknownError))
        }
      }
    }
  }
}

extension FetchAllCompetitionGroupedByCountryUseCase {
  enum FetchAllCompetitionGroupedByCountryError: Error {
    case dataLoadFailed
    case noDataAvailable
    case unknownError
  }
}
