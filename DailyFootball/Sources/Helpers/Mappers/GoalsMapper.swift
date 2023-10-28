//
//  GoalsMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct GoalsMapper: EntityMapperProtocol {
  typealias TableType = homeAwayGoalsTable?
  typealias EntityType = Goals
  
  static func mapEntity(from table: TableType) throws -> Goals {
    guard let table else { throw MappingError.missingData }
    return [
      .home: table.home,
      .away: table.away
    ]
  }
}
