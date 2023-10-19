//
//  CompetitionGroupMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/10.
//

import Foundation
import RealmSwift

struct CompetitionGroupMapper {
  static func toEntity(from table: Results<CompetitionTable>, followedCompetitions: Results<FollowedCompetitionTable>) -> [CompetitionGroup] {
    let groudpedLeagueTablesByCountry = Dictionary(grouping: table) { $0.country?.name ?? ""}
    
    let competitionGroups = groudpedLeagueTablesByCountry.map { (countryName, tables) in
      let competitions = tables.map { competitionTable in
        let isFollowed = followedCompetitions.contains(where: { $0.id == competitionTable.id })
        return Competition(id: competitionTable.id, title: competitionTable.name, logoURL: competitionTable.logo ?? "", type: competitionTable.type, country: competitionTable.country?.name ?? "", isFollowed: isFollowed)
      }
      let sortedCompetitions = competitions.sorted { $0.id < $1.id }
      let countryLogo = tables.first?.country?.flag ?? ""
      
      return CompetitionGroup(title: countryName, logoURL: countryLogo, competitions: sortedCompetitions)
    }
    
    let sortedCompetitionGroups = competitionGroups.sorted { $0.title < $1.title }
    return sortedCompetitionGroups
  }
}
