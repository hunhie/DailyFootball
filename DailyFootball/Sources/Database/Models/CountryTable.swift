//
//  CountryTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/03.
//

import Foundation
import RealmSwift

final class CountryTable: Object {
  @Persisted(primaryKey: true) var name: String
  @Persisted var code: String?
  @Persisted var flag: String?
  @Persisted var updateDate: Date
  
  convenience init(name: String, code: String? = nil, flag: String? = nil, updateDate: Date) {
    self.init()
    self.name = name
    self.code = code
    self.flag = flag
    self.updateDate = updateDate
  }
}
