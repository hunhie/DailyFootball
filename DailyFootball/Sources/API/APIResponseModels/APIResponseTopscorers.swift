//
//  APIResponseTopscorers.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

// MARK: - APIResponseTopscorers
struct APIResponseTopscorers: Decodable {
  let apiResponseTopscorersGet: String
  let parameters: Parameters
  let results: Int
  let paging: Paging
  let response: [Response]
  
  enum CodingKeys: String, CodingKey {
    case apiResponseTopscorersGet = "get"
    case parameters, results, paging, response
  }
}

extension APIResponseTopscorers {
  
  // MARK: - Paging
  struct Paging: Decodable {
    let current, total: Int
  }
  
  struct Parameters: Decodable {
    let league, season: String
  }
  
  // MARK: - Response
  struct Response: Decodable {
    let player: Player
    let statistics: [Statistic]
  }
  
  // MARK: - Player
  struct Player: Decodable {
    let id: Int
    let name: String
    let firstname, lastname: String?
    let age: Int
    let birth: Birth
    let nationality: String?
    let height, weight: String?
    let injured: Bool
    let photo: String
  }
  
  // MARK: - Birth
  struct Birth: Decodable {
    let date: String?
    let place: String?
    let country: String?
  }
  
  // MARK: - Statistic
  struct Statistic: Decodable {
    let team: Team
    let league: League
    let games: Games
    let substitutes: Substitutes
    let shots: Shots
    let goals: Goals
    let passes: Passes
    let tackles: Tackles
    let duels: Duels
    let dribbles: Dribbles
    let fouls: Fouls
    let cards: Cards
    let penalty: Penalty
  }
  
  // MARK: - Cards
  struct Cards: Decodable {
    let yellow, yellowred, red: Int
  }
  
  // MARK: - Dribbles
  struct Dribbles: Decodable {
    let attempts: Int?
    let success: Int?
  }
  
  // MARK: - Duels
  struct Duels: Decodable {
    let total: Int?
    let won: Int?
  }
  
  // MARK: - Fouls
  struct Fouls: Decodable {
    let drawn: Int?
    let committed: Int?
  }
  
  // MARK: - Games
  struct Games: Decodable {
    let appearences, lineups, minutes: Int
    let position: Position
    let rating: String?
    let captain: Bool
  }
  
  enum Position: String, Decodable {
    case attacker = "Attacker"
    case defender = "Defender"
    case midfielder = "Midfielder"
  }
  
  // MARK: - Goals
  struct Goals: Decodable {
    let total: Int?
    let conceded: Int?
    let assists: Int?
  }
  
  // MARK: - League
  struct League: Decodable {
    let id: Int
    let name: String
    let country: String
    let logo: String
    let flag: String?
    let season: Int
  }
  
  // MARK: - Passes
  struct Passes: Decodable {
    let total: Int?
    let key: Int?
    let accuracy: Int?
  }
  
  // MARK: - Penalty
  struct Penalty: Decodable {
    let scored: Int?
    let missed: Int?
  }
  
  // MARK: - Shots
  struct Shots: Decodable {
    let total: Int?
    let on: Int?
  }
  
  // MARK: - Substitutes
  struct Substitutes: Decodable {
    let substitutesIn, out, bench: Int?
    
    enum CodingKeys: String, CodingKey {
      case substitutesIn = "in"
      case out, bench
    }
  }
  
  // MARK: - Tackles
  struct Tackles: Decodable {
    let total, blocks, interceptions: Int?
  }
  
  // MARK: - Team
  struct Team: Decodable {
    let id: Int
    let name: String
    let logo: String
  }
}
