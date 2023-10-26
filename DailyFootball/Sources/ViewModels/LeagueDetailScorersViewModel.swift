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
        self.state.value = .scorersLoaded(response)
      case .failure(let error):
        self.state.value = .error(error)
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
    case scorersLoaded([Scorer])
    case error(Error)
  }
}
