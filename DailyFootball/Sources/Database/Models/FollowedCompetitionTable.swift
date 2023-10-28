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
  @Persisted var info: CompetitionInfoTable?
  @Persisted var country: CountryTable?
  @Persisted var seasons: List<SeasonTable>
  
  convenience init(id: Int, info: CompetitionInfoTable?, country: CountryTable?, seasons: List<SeasonTable>) {
    self.init()
    self.id = id
    self.info = info
    self.country = country
    self.seasons = seasons
  }
}
