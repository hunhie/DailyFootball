//
//  CompetitionInfoTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RealmSwift

final class CompetitionInfoTable: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var name: String
  @Persisted var type: String
  @Persisted var logoURL: String?

  convenience init(id: Int, name: String, type: String, logoURL: String?) {
    self.init()
    self.id = id
    self.name = name
    self.type = type
    self.logoURL = logoURL
  }
}
