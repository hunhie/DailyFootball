//
//  VenueMapper.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

struct VenueMapper {
  static func mapEntity(from table: VenueTable?) throws -> Venue {
    guard let id = table?.id else { throw MappingError.missingData }
    return Venue(id: id, name: table?.name, city: table?.city)
  }
}
