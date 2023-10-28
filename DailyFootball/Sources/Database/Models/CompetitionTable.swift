//
//  CompetitionTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class CompetitionTable: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var info: CompetitionInfoTable?
  @Persisted var country: CountryTable?
  @Persisted var seasons: List<SeasonTable>
  @Persisted var updateDate: Date

  convenience init(id: Int, info: CompetitionInfoTable?, country: CountryTable?, seasons: List<SeasonTable>) {
    self.init()
    self.id = id
    self.info = info
    self.country = country
    self.seasons = seasons
    self.updateDate = Date()
  }
}
