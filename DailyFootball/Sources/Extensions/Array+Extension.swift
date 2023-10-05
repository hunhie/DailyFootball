//
//  Array+Extension.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import Foundation

extension Array {
  subscript(safe index: Int) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
