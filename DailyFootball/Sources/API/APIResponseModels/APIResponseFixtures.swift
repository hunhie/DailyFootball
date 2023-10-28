//
//  APIResponseFixtures.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

// MARK: - APIResponseFixtures
struct APIResponseFixtures: Decodable {
  let apiResponseSGet: String
  let parameters: Parameters
  let results: Int
  let paging: Paging
  let response: [Response]
  
  enum CodingKeys: String, CodingKey {
    case apiResponseSGet = "get"
    case parameters, results, paging, response
  }
}

extension APIResponseFixtures {
  
  // MARK: - Paging
  struct Paging: Decodable {
    let current, total: Int
  }
  
  // MARK: - Parameters
  struct Parameters: Decodable {
    let league, date, timezone, season: String
  }
  
  // MARK: - Response
  struct Response: Decodable {
    let fixture: Fixture
    let league: League
    let teams: Teams
    let goals: Goals
    let score: Score
  }
  
  // MARK: - Fixture
  struct Fixture: Decodable {
    let id: Int
    let referee, timezone: String
    let date: String
    let timestamp: Int
    let periods: Periods
    let venue: Venue
    let status: Status
  }
  
  //MARK: - Teams
  struct Teams: Decodable {
      let home: Team
      let away: Team
  }

  struct Team: Decodable {
      let id: Int
      let name: String
      let logo: String?
      let winner: Bool?
  }
  
  // MARK: - Periods
  struct Periods: Decodable {
    let first, second: Int?
  }
  
  // MARK: - Status
  struct Status: Decodable {
    let long, short: String
    let elapsed: Int?
  }
  
  // MARK: - Venue
  struct Venue: Decodable {
    let id: Int
    let name, city: String?
  }
  
  // MARK: - Goals
  struct Goals: Decodable {
    let home, away: Int?
  }
  
  // MARK: - League
  struct League: Decodable {
    let id: Int
    let name, country: String
    let logo: String
    let flag: String
    let season: Int
    let round: String
  }
  
  // MARK: - Score
  struct Score: Decodable {
    let halftime, fulltime, extratime, penalty: Goals
  }
}
