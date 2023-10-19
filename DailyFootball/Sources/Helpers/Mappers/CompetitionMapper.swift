//
//  CompetitionMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/12.
//

import Foundation
import RealmSwift

struct CompetitionMapper {
  static func toEntity(from table: Results<FollowedCompetitionTable>) -> [Competition] {
    let competitions: [Competition] = table.map {
      Competition(id: $0.id, title: $0.title, logoURL: $0.logoURL, type: $0.type, country: $0.country, isFollowed: true)
    }
    return competitions
  }
}
