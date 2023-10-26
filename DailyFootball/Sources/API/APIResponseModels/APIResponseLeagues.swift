//
//  APIResponseLeagues.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation

// MARK: - APIResponseLeagues
struct APIResponseLeagues: Decodable {
  let get: String
  let errors: [String]
  let results: Int
  let paging: Paging
  let response: [Response]
  
  enum CodingKeys: String, CodingKey {
    case get, errors, results, paging, response
  }
}

extension APIResponseLeagues {
  
  // MARK: - Paging
  struct Paging: Decodable {
    let current, total: Int
  }
  
  // MARK: - Response
  struct Response: Decodable {
    let league: League
    let country: Country
    let seasons: [Season]
  }
  
  // MARK: - Country
  struct Country: Decodable {
    let name: String
    let code: String?
    let flag: String?
  }
  
  // MARK: - League
  struct League: Decodable {
    let id: Int
    let name: String
    let type: TypeEnum
    let logo: String
  }
  
  enum TypeEnum: String, Decodable {
    case cup = "Cup"
    case league = "League"
  }
  
  // MARK: - Season
  struct Season: Decodable {
    let year: Int
    let start, end: String
    let current: Bool
    let coverage: Coverage
  }
  
  // MARK: - Coverage
  struct Coverage: Decodable {
    let fixtures: Fixtures
    let standings, players, topScorers, topAssists: Bool
    let topCards, injuries, predictions, odds: Bool
    
    enum CodingKeys: String, CodingKey {
      case fixtures, standings, players
      case topScorers = "top_scorers"
      case topAssists = "top_assists"
      case topCards = "top_cards"
      case injuries, predictions, odds
    }
  }
  
  // MARK: - Fixtures
  struct Fixtures: Decodable {
    let events, lineups, statisticsFixtures, statisticsPlayers: Bool
    
    enum CodingKeys: String, CodingKey {
      case events, lineups
      case statisticsFixtures = "statistics_fixtures"
      case statisticsPlayers = "statistics_players"
    }
  }
}
