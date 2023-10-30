//
//  VenueTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RealmSwift

final class VenueTable: Object {
    @Persisted(primaryKey: true) var id: Int?
    @Persisted var name: String?
    @Persisted var city: String?
}
