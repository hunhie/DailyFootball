//
//  APIFootballError.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation

enum APIFootballError: Error {
  case decodingError
  case noData
  case timeout
  case serverError
  case unknown
}
