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
}

extension APIFootballTarget: TargetType {
  var path: String {
    switch self {
    case .leagues: return "leagues"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .leagues: return .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .leagues: return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    ["X-RapidAPI-Key": APIKeys.apifootball.rawValue]
  }
  
  var baseURL: URL {
    URL(string: "https://api-football-v1.p.rapidapi.com/v3/")!
  }
}
