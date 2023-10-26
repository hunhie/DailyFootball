//
//  APIResponseStandings.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/24.
//

import Foundation

// MARK: - Welcome
struct APIResponseStandings: Decodable {
  let get: String
  let errors: [String]
  let results: Int
  let paging: Paging
  let response: [Response]
  
  enum CodingKeys: String, CodingKey {
    case get, errors, results, paging, response
  }
}

extension APIResponseStandings {
  
  // MARK: - Paging
  struct Paging: Decodable {
    let current, total: Int
  }
  
  // MARK: - Response
  struct Response: Decodable {
    let league: League
  }
  
  // MARK: - League
  struct League: Decodable {
    let id: Int
    let name: String
    let country: String
    let logo: String
    let flag: String?
    let season: Int
    let standings: [[Standing]]
  }
  
  // MARK: - Standing
  struct Standing: Decodable {
    let rank: Int
    let team: Team
    let points, goalsDiff: Int
    let group: String
    let form: String
    let status: String
    let description: String?
    let all, home, away: All
  }
  
  // MARK: - All
  struct All: Decodable {
    let played, win, draw, lose: Int
    let goals: Goals
  }
  
  // MARK: - Goals
  struct Goals: Decodable {
    let goalsFor, against: Int
    
    enum CodingKeys: String, CodingKey {
      case goalsFor = "for"
      case against
    }
  }
  
  // MARK: - Team
  struct Team: Decodable {
    let id: Int
    let name: String
    let logo: String
  }
}
