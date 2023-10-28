//
//  StandingTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/27.
//

import Foundation
import RealmSwift

final class StandingTable: Object {
    @Persisted var rank: Int
    @Persisted var team: TeamTable?
    @Persisted var points: Int
    @Persisted var goalsDiff: Int
    @Persisted var group: String
    @Persisted var form: String
    @Persisted var status: String
    @Persisted var desc: String?
    @Persisted var all: GameRecordTable?
    @Persisted var home: GameRecordTable?
    @Persisted var away: GameRecordTable?
}

final class GameRecordTable: EmbeddedObject {
    @Persisted var played: Int
    @Persisted var win: Int
    @Persisted var draw: Int
    @Persisted var lose: Int
    @Persisted var goalsFor: Int
    @Persisted var goalsAgainst: Int
}
