//
//  MatchesViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

final class MatchesViewModel {
  
  var state: Observable<State> = Observable(.idle)
  
//  func handle(action: Action) {
//    switch action {
//    case .fetchFixtures:
//      
//    case .showIndicator:
//      state.value = .loading
//    }
//  }
}

//MARK: - Action & State
extension MatchesViewModel {
  enum Action {
    case fetchFixtures
    case showIndicator
  }
  
  enum State {
    case idle
    case loading
    case loaded
    case error(MatchesError)
  }
  
  enum MatchesError {
    case serverError
    case networkError
    case noFollowedCompetition
  }
}
