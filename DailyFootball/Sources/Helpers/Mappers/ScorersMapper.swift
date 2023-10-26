//
//  ScorersMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

struct ScorersMapper {
  static func toEntity(from tables: LeagueTopScorersTable) -> [Scorer] {
    let id = tables.id
    
    return tables.topScorers.map { table in
      let playerTable = table.player!
      let player = Player(id: playerTable.id, name: playerTable.name, firstname: playerTable.firstname, lastname: playerTable.lastname, age: playerTable.age, birthDate: playerTable.birthDate, nationality: playerTable.nationality, height: playerTable.height, weight: playerTable.weight, injured: playerTable.injured, photo: playerTable.photo)
      return Scorer(id: id, rank: table.rank, player: player, goals: table.statistics?.goals?.total ?? 0)
    }
  }
}
