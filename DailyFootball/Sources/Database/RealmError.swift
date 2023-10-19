//
//  RealmError.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/06.
//

import Foundation

enum RealmError: Error {
  case initializedFailed
  case writeFailed
  case DataEmpty
}
