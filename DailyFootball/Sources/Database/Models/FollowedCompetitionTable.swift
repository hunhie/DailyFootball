//
//  FollowedCompetitionTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import Foundation
import RealmSwift

final class FollowedCompetitionTable: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var title: String
  @Persisted var logoURL: String
  @Persisted var type: String
  @Persisted var country: String

  convenience init(id: Int, title: String, logoURL: String, type: String, country: String) {
    self.init()
    self.id = id
    self.title = title
    self.logoURL = logoURL
    self.type = type
    self.country = country
  }
}
