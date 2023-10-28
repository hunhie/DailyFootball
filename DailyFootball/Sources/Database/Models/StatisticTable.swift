//
//  StatisticTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

final class StatisticTable: EmbeddedObject {
  @Persisted var team: TeamTable?
  @Persisted var games: GameTable?
  @Persisted var substitutes: SubstitutesTable?
  @Persisted var shots: ShotsTable?
  @Persisted var goals: GoalsTable?
  @Persisted var passes: PassesTable?
  @Persisted var tackles: TacklesTable?
  @Persisted var duels: DuelsTable?
  @Persisted var dribbles: DribblesTable?
  @Persisted var fouls: FoulsTable?
  @Persisted var cards: CardsTable?
  @Persisted var penalty: PenaltyTable?
}

final class SubstitutesTable: EmbeddedObject {
  @Persisted var substitutesIn: Int
  @Persisted var out: Int
  @Persisted var bench: Int
}

final class ShotsTable: EmbeddedObject {
  @Persisted var total: Int
  @Persisted var on: Int
}

final class GoalsTable: EmbeddedObject {
  @Persisted var total: Int
  @Persisted var conceded: Int
  @Persisted var assists: Int?
}

final class PassesTable: EmbeddedObject {
  @Persisted var total: Int
  @Persisted var key: Int
  @Persisted var accuracy: Int
}

final class TacklesTable: EmbeddedObject {
  @Persisted var total: Int
  @Persisted var blocks: Int?
  @Persisted var interceptions: Int?
}

final class DuelsTable: EmbeddedObject {
  @Persisted var total: Int
  @Persisted var won: Int
}

final class DribblesTable: EmbeddedObject {
  @Persisted var attempts: Int
  @Persisted var success: Int
}

final class FoulsTable: EmbeddedObject {
  @Persisted var drawn: Int
  @Persisted var committed: Int
}

final class CardsTable: EmbeddedObject {
  @Persisted var yellow: Int
  @Persisted var yellowred: Int
  @Persisted var red: Int
}

final class PenaltyTable: EmbeddedObject {
  @Persisted var scored: Int
  @Persisted var missed: Int
}
