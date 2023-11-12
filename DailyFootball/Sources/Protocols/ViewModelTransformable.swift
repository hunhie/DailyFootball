//
//  ViewModelTransformable.swift
//  DailyFootball
//
//  Created by walkerhilla on 11/10/23.
//

import Foundation

protocol ViewModelTransformable {
  associatedtype Input
  associatedtype Output
  
  func transform(_ input: Input) -> Output
}
