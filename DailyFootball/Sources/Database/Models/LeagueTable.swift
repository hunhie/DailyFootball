//
//  LeagueTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class LeagueTable: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var name: String
  @Persisted var type: String
  @Persisted var logo: String?
  @Persisted var country: CountryTable?
  @Persisted var seasons: List<SeasonTable>
  
  convenience init(id: Int, name: String, type: String, logo: String? = nil, country: CountryTable? = nil, seasons: List<SeasonTable>) {
    self.init()
    self.id = id
    self.name = name
    self.type = type
    self.logo = logo
    self.country = country
    self.seasons = seasons
  }
}
