//
//  TeamTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RealmSwift

final class TeamTable: Object {
  @Persisted var id: Int
  @Persisted var name: String
  @Persisted var logo: String?
  
  convenience init(id: Int, name: String, logo: String?) {
    self.init()
    self.id = id
    self.name = name
    self.logo = logo
  }
}
