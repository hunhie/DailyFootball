//
//  TeamMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct TeamMapper: EntityMapperProtocol {
  typealias TableType = TeamsTable?
  typealias EntityType = Teams?
  
  static func mapTable(from entity: EntityType) throws -> TableType {
    guard let entity,
          let away = entity[.away],
          let home = entity[.home] else { throw MappingError.missingData }
    
    let table = TeamsTable()
    table.away = TeamTable(id: away.id, name: away.name, logo: away.logoURL)
    table.home = TeamTable(id: home.id, name: home.name, logo: home.logoURL)
    return table
  }
  
  static func mapEntity(from table: TableType) -> Teams? {
    guard let away = table?.away,
          let home = table?.home else { return nil }
    let awayTeam = Team(id: away.id, name: away.name, logoURL: away.logo)
    let homeTeam = Team(id: home.id, name: home.name, logoURL: home.logo)
    return [.away: awayTeam, .home: homeTeam]
  }
}
