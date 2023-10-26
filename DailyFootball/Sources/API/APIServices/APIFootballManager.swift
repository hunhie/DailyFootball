//
//  APIFootballManager.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation
import Moya

struct APIFootballManager {
  
  private let provider = MoyaProvider<APIFootballTarget>()

  func request<Model: Decodable>(_ target: APIFootballTarget, completion: @escaping (Result<Model, APIFootballError>) -> ()) {
    provider.request(target) { result in
      switch result {
      case .success(let response):
        switch response.statusCode {
        case 200:
          do {
            let decodedResponse = try JSONDecoder().decode(Model.self, from: response.data)
            completion(.success(decodedResponse))
          } catch let decodingError {
            dump(decodingError)
            completion(.failure(.decodingError))
          }
        case 204:
          completion(.failure(.noData))
        case 499:
          completion(.failure(.timeout))
        case 500:
          completion(.failure(.serverError))
        default:
          completion(.failure(.unknownError))
        }
      case .failure(let error):
        dump(error)
        completion(.failure(.unknownError))
      }
    }
  }
}
