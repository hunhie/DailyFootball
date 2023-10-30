//
//  CompetitionInfo.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

struct CompetitionInfo: Hashable {
  var id: Int
  var name: String
  var type: String
  var logoURL: String
  
  var cpType: CompetitionType {
    switch type {
    case "League": return .leauge
    case "Cup": return .cup
    default: return .leauge
    }
  }
  
  enum CompetitionType {
    case leauge
    case cup
  }
}
