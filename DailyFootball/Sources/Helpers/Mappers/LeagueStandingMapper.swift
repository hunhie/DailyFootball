//
//  Standing.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/25.
//

import Foundation
import RealmSwift

struct StandingMapper {
  static func toEntity(from tables: List<StandingTable>) -> [Standing] {
    return tables.map { table in
      let teamTable = table.team!
      let all = table.all!
      let home = table.home!
      let away = table.away!
      return Standing(
        rank: table.rank,
        team: Standing.LeagueTeam(
          id: teamTable.id,
          name: teamTable.name,
          logoURL: teamTable.logo
        ),
        group: table.group,
        point: table.points,
        goalsDiff: table.goalsDiff,
        description: table.desc ?? "",
        all: Standing.GameRecord(
          played: all.played,
          win: all.win,
          draw: all.draw,
          lose: all.lose,
          goalsFor: all.goalsFor,
          goalsAgainst: all.goalsAgainst
        ),
        home: Standing.GameRecord(
          played: home.played,
          win: home.win,
          draw: home.draw,
          lose: home.lose,
          goalsFor: home.goalsFor,
          goalsAgainst: home.goalsAgainst
        ),
        away: Standing.GameRecord(
          played: away.played,
          win: away.win,
          draw: away.draw,
          lose: away.lose,
          goalsFor: away.goalsFor,
          goalsAgainst: away.goalsAgainst
        )
      )
    }
  }
}

