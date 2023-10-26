//
//  GameTable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RealmSwift

final class GameTable: Object {
    @Persisted var appearences: Int
    @Persisted var lineups: Int
    @Persisted var minutes: Int
    @Persisted private var _position: String
    @Persisted var rating: String
    @Persisted var captain: Bool
  
  var position: Position {
      get { return Position(rawValue: _position) ?? .midfielder }
      set { _position = newValue.rawValue }
  }
}
