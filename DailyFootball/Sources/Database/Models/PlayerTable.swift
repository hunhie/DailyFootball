//
//  PlayerTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

final class PlayerTable: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var firstname: String?
    @Persisted var lastname: String?
    @Persisted var age: Int
    @Persisted var birthDate: String?
    @Persisted var birthPlace: String?
    @Persisted var birthCountry: String?
    @Persisted var nationality: String?
    @Persisted var height: String?
    @Persisted var weight: String?
    @Persisted var injured: Bool
    @Persisted var photo: String
}
