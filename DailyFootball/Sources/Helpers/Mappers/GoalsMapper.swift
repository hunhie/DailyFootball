//
//  GoalsMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct GoalsMapper: EntityMapperProtocol {
  typealias TableType = HomeAwayGoalsTable?
  typealias EntityType = Goals?
  
  static func mapEntity(from table: TableType) -> Goals? {
    guard let table else { return nil }
    return [
      .home: table.home,
      .away: table.away
    ]
  }
}
