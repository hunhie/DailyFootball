//
//  TopScorerTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

final class TopScorerTable: EmbeddedObject {
    @Persisted var rank: Int = 0
    @Persisted var player: PlayerTable?
    @Persisted var statistics: StatisticTable?
}
