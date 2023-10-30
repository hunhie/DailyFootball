//
//  FixtureGroupMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RealmSwift

struct FixtureGroupMapper: EntityMapperProtocol {
  typealias TableType = CompetitionFixtureTable
  typealias EntityType = FixtureGroupByCompetition
  
  static func mapEntity(from table: TableType) throws -> EntityType {
    let fixtures = FixtureMapper.mapEntity(from: table.fixtureData)
    let info = try CompetitionMapper.mapCompetitionInfo(from: table.info)
    let country = CountryMapper.mapCountry(from: table.country)

    return FixtureGroupByCompetition(season: table.season, info: info, country: country, fixtures: fixtures)
  }
}
