//
//  CountryMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation

struct CountryMapper {
  static func mapCountryTable(from coutnry: Country) -> CountryTable {
    return CountryTable(name: coutnry.name, code: coutnry.code, flag: coutnry.flagURL)
  }
  
  static func mapCountry(from table: CountryTable?) -> Country {
    return Country(name: table?.name ?? "", code: table?.code ?? "", flagURL: table?.flag ?? "")
  }
}
