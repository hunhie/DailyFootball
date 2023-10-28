//
//  SeasonTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class SeasonTable: Object {
  @Persisted(primaryKey: true) var uid: String
  @Persisted var id: Int
  @Persisted var year: Int
  @Persisted var start: Date?
  @Persisted var end: Date?
  @Persisted var current: Bool
  @Persisted var coverage: CoverageTable?
  
  convenience init(uid: String, id: Int, year: Int, start: Date?, end: Date?, current: Bool, coverage: CoverageTable?) {
    self.init()
    self.uid = uid
    self.id = id
    self.year = year
    self.start = start
    self.end = end
    self.current = current
    self.coverage = coverage
  }
}
