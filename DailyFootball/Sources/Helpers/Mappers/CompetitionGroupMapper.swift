//
//  CompetitionGroupMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/10.
//

import Foundation
import RealmSwift

struct CompetitionGroupMapper {
  static func mapCompetitionGroups(from table: Results<CompetitionTable>, followedCompetitions: Results<FollowedCompetitionTable>) throws -> [CompetitionGroupByCountry] {
    do {
      let groudpedLeagueTablesByCountry = Dictionary(grouping: table) { $0.country?.name ?? ""}
      let competitionGroups = try groudpedLeagueTablesByCountry.map { (countryName, tables) -> CompetitionGroupByCountry in
        let competitions = try tables.map { competitionTable -> Competition in
          let isFollowed = followedCompetitions.contains(where: { $0.id == competitionTable.id })
          
          let seasons = CompetitionMapper.mapSeasons(from: competitionTable.seasons)
          let leagueInfo = try CompetitionMapper.mapCompetitionInfo(from: competitionTable.info)
          
          return Competition(
            id: competitionTable.id,
            info: leagueInfo,
            country: CountryMapper.mapCountry(from: competitionTable.country),
            isFollowed: isFollowed,
            season: seasons
          )
        }
        
        let sortedCompetitions = competitions.sorted { $0.id < $1.id }
        let country = CountryMapper.mapCountry(from: tables.first?.country)
        
        return CompetitionGroupByCountry(country: country, competitions: sortedCompetitions)
      }
      
      let sortedCompetitionGroups = competitionGroups.sorted { $0.country.name < $1.country.name }
      return sortedCompetitionGroups
    } catch {
      throw MappingError.missingData
    }
  }
}
