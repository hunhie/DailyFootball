//
//  MatchesViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RxSwift

final class MatchesViewModel: ViewModelTransformable {
  struct Input {
    let viewDidLoad: PublishSubject<Date>
    
  }
  
  struct Output {
    let fixtures: PublishSubject<[FixtureGroupByCompetition]>
  }
  
  private let fetchFixtureByFollowedCompetitionUseCase = FetchFixturesByFollowedCompetitionUseCase()
  private let disposeBag = DisposeBag()

  func transform(_ input: Input) -> Output {
    let matches = PublishSubject<[FixtureGroupByCompetition]>()
    
    input.viewDidLoad
      .flatMap { [weak self] value -> Single<[FixtureGroupByCompetition]> in
        guard let self else { return Single.error(MatchesError.serverError) }
        return fetchFixtureByFollowedCompetitionUseCase.execute(date: value)
      }
      .subscribe(with: self) { owner, value in
        matches.onNext(value)
      } onError: { owner, error in
        matches.onError(error)
      }
      .disposed(by: disposeBag)

    return Output(fixtures: matches)
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
  
  enum MatchesError: Error {
    case serverError
    case noFollowedCompetition
  }
}
