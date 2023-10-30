//
//  LeagueDetailScorersViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

final class LeagueDetailScorersViewModel {
  
  private let fetchLeagueScorersUseCase = FetchLeagueScorersUseCase()
  
  var state: Observable<State> = Observable(.idle)
  
  func handle(action: Action) {
    switch action {
    case .fetchStandings(let season, let id):
    fetchScorers(season: season, id: id)
    }
  }
  
  private func fetchScorers(season: Int, id: Int) {
    fetchLeagueScorersUseCase.execute(season: season, id: id) { result in
      switch result {
      case .success(let response):
        if !response.isEmpty {
          self.state.value = .loaded
          self.state.value = .scorersLoaded(response)
        } else {
          self.state.value = .error(.dataEmpty)
        }
      case .failure:
        self.state.value = .loaded
        self.state.value = .error(.serverError)
      }
    }
  }
}


extension LeagueDetailScorersViewModel {
  enum Action {
    case fetchStandings(season: Int, id: Int)
  }
  
  enum State {
    case idle
    case loading
    case loaded
    case scorersLoaded([Scorer])
    case error(LeagueDetailScorersViewError)
  }
  
  enum LeagueDetailScorersViewError: Error {
    case dataEmpty
    case networkError
    case serverError
  }
}
