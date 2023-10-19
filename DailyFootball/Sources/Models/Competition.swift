//
//  Competition.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/02.
//

import Foundation

struct Competition: Hashable {
  var id: Int
  var title: String
  var logoURL: String
  var type: String
  var country: String
  var isFollowed: Bool
  
  static func == (lhs: Competition, rhs: Competition) -> Bool {
    return lhs.id == rhs.id && lhs.isFollowed == rhs.isFollowed
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(isFollowed)
  }
}
