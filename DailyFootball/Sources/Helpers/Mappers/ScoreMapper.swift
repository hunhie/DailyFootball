//
//  TimeMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct ScoreMapper: EntityMapperProtocol {
  typealias TableType = ScoreTable?
  typealias EntityType = Score
  
  static func mapEntity(from table: ScoreTable?) throws -> Score {
    guard let table else { throw MappingError.missingData }
    
    var scoreDict: EntityType = [:]
    
    do {
      if let halftime = table.halftime {
        scoreDict[.halfTime] = try GoalsMapper.mapEntity(from: halftime)
      }
      
      if let fulltime = table.fulltime {
        scoreDict[.fullTime] = try GoalsMapper.mapEntity(from: fulltime)
      }
      
      if let extratime = table.extratime {
        scoreDict[.extraTime] = try GoalsMapper.mapEntity(from: extratime)
      }
      
      if let penalty = table.penalty {
        scoreDict[.penalty] = try GoalsMapper.mapEntity(from: penalty)
      }
    } catch {
      throw MappingError.missingData
    }
    
    return scoreDict
  }
}
