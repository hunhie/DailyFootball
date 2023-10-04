//
//  Observable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/04.
//

import Foundation

final class Observable<T> {
  typealias Listener = (T) -> ()
  private var listener: Listener?
  
  var value: T {
    didSet {
      listener?(value)
    }
  }
  
  init(_ value: T) {
    self.value = value
  }
  
  func bind(_ closure: @escaping Listener) {
    closure(value)
    listener = closure
  }
}
