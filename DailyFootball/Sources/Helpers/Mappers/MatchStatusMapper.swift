//
//  MatchStatusMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct MatchStatusMapper: EntityMapperProtocol {
  typealias TableType = StatusTable?
  typealias EntityType = MatchStatus?
  
  static func mapEntity(from table: TableType) -> MatchStatus? {
    guard let table = table else { return nil }
    switch table.short {
    case "TBD":
      return .scheduled(.toBeDefined)
    case "NS":
      return .scheduled(.notStarted)
    case "1H":
      return .inPlay(.firstHalf)
    case "HT":
      return .inPlay(.halftime)
    case "2H":
      return .inPlay(.secondHalf)
    case "ET":
      return .inPlay(.extraTime)
    case "BT":
      return .inPlay(.breakTime)
    case "P":
      return .inPlay(.penaltyInProgress)
    case "SUSP":
      return .inPlay(.suspended)
    case "INT":
      return .inPlay(.interrupted)
    case "FT":
      return .finished(.regularTime)
    case "AET":
      return .finished(.afterExtraTime)
    case "PEN":
      return .finished(.afterPenaltyShootout)
    case "PST":
      return .postponed
    case "CANC":
      return .cancelled
    case "ABD":
      return .abandoned
    case "AWD":
      return .notPlayed(.technicalLoss)
    case "WO":
      return .notPlayed(.walkOver)
    case "LIVE":
      return .inPlay(.live)
    default:
      return nil
    }
  }
}
