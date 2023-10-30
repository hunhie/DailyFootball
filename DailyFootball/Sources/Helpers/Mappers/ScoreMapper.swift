//
//  TimeMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct ScoreMapper: EntityMapperProtocol {
  typealias TableType = ScoreTable?
  typealias EntityType = Score?
  
  static func mapEntity(from table: ScoreTable?) -> Score? {
    guard let table else { return nil }
    
    var scoreDict: Score = [:]
    
    if let halftime = table.halftime {
      scoreDict[.halfTime] = GoalsMapper.mapEntity(from: halftime)
    }
    
    if let fulltime = table.fulltime {
      scoreDict[.fullTime] = GoalsMapper.mapEntity(from: fulltime)
    }
    
    if let extratime = table.extratime {
      scoreDict[.extraTime] = GoalsMapper.mapEntity(from: extratime)
    }
    
    if let penalty = table.penalty {
      scoreDict[.penalty] = GoalsMapper.mapEntity(from: penalty)
    }
    
    return scoreDict
  }
}
