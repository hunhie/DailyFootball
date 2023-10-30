//
//  MatchesViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation

final class MatchesViewModel {

  private let fetchFixtureByFollowedCompetitionUseCase = FetchFixturesByFollowedCompetitionUseCase()
  
  var fixtureGroups: [FixtureGroupByCompetition] = []
  
  var state: Observable<State> = Observable(.idle)
  
  func handle(action: Action) {
    switch action {
    case .fetchFixtureGroupByCompetition(let date):
      fetchFixtureGroupByCompetition(date: date)
    case .toggleFixtureGroup(let group):
      toggleFixtureGroup(for: group)
    case .showIndicator:
      state.value = .loading
    }
  }
  
  private func fetchFixtureGroupByCompetition(date: Date) {
    fetchFixtureByFollowedCompetitionUseCase.execute(date: date) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let success):
        state.value = .loaded
        state.value = .fixtureGroupByCompetitionLoaded(success)
        fixtureGroups = success
      case .failure(let error):
        state.value = .loaded
        switch error {
        case .dataLoadFailed:
          state.value = .error(.serverError)
        case .noFollowCompetition:
          state.value = .error(.noFollowedCompetition)
        }
      }
    }
  }
  
  private func toggleFixtureGroup(for group: FixtureGroupByCompetition) {
    if let index = fixtureGroups.firstIndex(where: {
      $0 == group
    }) {
      fixtureGroups[index].isExpanded.toggle()
      state.value = .fixtureGroupByCompetitionToggled(fixtureGroups)
    }
  }
}

//MARK: - Action & State
extension MatchesViewModel {
  enum Action {
    case fetchFixtureGroupByCompetition(date: Date)
    case showIndicator
    case toggleFixtureGroup(FixtureGroupByCompetition)
  }
  
  enum State {
    case idle
    case loading
    case loaded
    case fixtureGroupByCompetitionLoaded([FixtureGroupByCompetition])
    case fixtureGroupByCompetitionToggled([FixtureGroupByCompetition])
    case error(MatchesError)
  }
  
  enum MatchesError {
    case serverError
    case noFollowedCompetition
  }
}
