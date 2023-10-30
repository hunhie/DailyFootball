//
//  VenueMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct VenueMapper {
  static func mapEntity(from table: VenueTable?) -> Venue? {
    guard let table = table else { return nil}
    return Venue(id: table.id, name: table.name, city: table.city)
  }
}
