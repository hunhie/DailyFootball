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
  
  func execute(completion: @escaping (Result<[CompetitionGroupByCountry], FetchAllCompetitionGroupedByCountryError>) -> ()) {
    competitionGroupRepo.fetchData { result in
      switch result {
      case .success(let response):
        userCompetitionFollowsRepo.fetchFollowedCompetitions { followResult in
          switch followResult {
          case .success(let followedCompetitions):
            do {
              var data = try CompetitionGroupMapper.mapCompetitionGroups(from: response, followedCompetitions: followedCompetitions)
              let userCountryCode = Locale.current.language.region?.identifier ?? ""

              // data 배열을 다음의 우선 순위에 따라 정렬합니다:
              // 1. 사용자의 기기 설정 국가 코드와 일치하는 항목.
              // 2. 국가 이름이 "World"인 항목.
              // 3. 나머지 항목을 국가 이름의 알파벳 순서대로 정렬.
              data.sort {
                  if $0.country.code == userCountryCode { return true }
                  if $1.country.code == userCountryCode { return false }
                  if $0.country.name == "World" { return true }
                  if $1.country.name == "World" { return false }
                  return $0.country.name < $1.country.name
              }

              completion(.success(data))
            } catch {
              completion(.failure(.noDataAvailable))
            }
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
