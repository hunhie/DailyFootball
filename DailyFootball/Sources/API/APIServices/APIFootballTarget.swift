//
//  APIFootballTarget.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import Moya

enum APIFootballTarget {
  case leagues
  case standings(season: Int, id: Int)
  case topScorers(season: Int, id: Int)
  case fixtures(date: String, season: Int, id: Int, timezone: String, status: String?)
}

extension APIFootballTarget: TargetType {
  var path: String {
    switch self {
    case .leagues: return "leagues"
    case .standings: return "standings"
    case .topScorers: return "players/topscorers"
    case .fixtures: return "fixtures"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .leagues: return .get
    case .standings: return .get
    case .topScorers: return .get
    case .fixtures: return .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .leagues: return .requestPlain
    case .standings(let season, let id):
      let parameters = ["season": "\(season)", "league": "\(id)"]
      return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    case .topScorers(let season, let id):
      let parameters = ["season": "\(season)", "league": "\(id)"]
      return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    case .fixtures(let date, let season, let id, let timezone, let status):
      var parameters = [String: String]()
      parameters["date"] = date
      parameters["season"] = "\(season)"
      parameters["league"] = "\(id)"
      parameters["timezone"] = timezone
      if let status = status { parameters["status"] = status }
      return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
  }
  
  var headers: [String : String]? {
    ["X-RapidAPI-Key": APIKeys.apifootball.rawValue]
  }
  
  var baseURL: URL {
    URL(string: "https://api-football-v1.p.rapidapi.com/v3/")!
  }
}
