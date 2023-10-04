//
//  SeasonTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class SeasonTable: EmbeddedObject {
  @Persisted var year: Int
  @Persisted var start: Date?
  @Persisted var end: Date?
  @Persisted var current: Bool
  @Persisted var coverage: CoverageTable
  
  convenience init(year: Int, start: Date?, end: Date?, current: Bool, coverage: CoverageTable) {
    self.init()
    self.year = year
    self.start = start
    self.end = end
    self.current = current
    self.coverage = coverage
  }
}
