//
//  Position.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

enum Position: String, RealmEnum {
    case attacker = "Attacker"
    case defender = "Defender"
    case midfielder = "Midfielder"
}
