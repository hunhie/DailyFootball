//
//  APIFootballManager.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation
import Moya
import RxSwift

struct APIFootballManager {
  
  private let provider = MoyaProvider<APIFootballTarget>()
  
  func request<Model: Decodable>(_ target: APIFootballTarget) -> Single<Model> {
    return Single<Model>.create { single in
      self.provider.request(target) { result in
        switch result {
        case .success(let response):
          switch response.statusCode {
          case 200:
            do {
              let decodedResponse = try JSONDecoder().decode(Model.self, from: response.data)
              single(.success(decodedResponse))
            } catch let decodingError {
              dump(decodingError)
              single(.failure(APIFootballError.decodingError))
            }
          case 204:
            single(.failure(APIFootballError.noData))
          case 499:
            single(.failure(APIFootballError.timeout))
          case 500:
            single(.failure(APIFootballError.serverError))
          default:
            single(.failure(APIFootballError.unknownError))
          }
        case .failure:
          single(.failure(APIFootballError.unknownError))
        }
      }
      return Disposables.create()
    }
  }
}
