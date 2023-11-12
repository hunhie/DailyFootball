//
//  MatchesViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RxSwift
import RxRelay

final class MatchesViewModel: ViewModelTransformable {
  private let matches = PublishSubject<[FixtureGroupByCompetition]>()
  private var matchesData: [FixtureGroupByCompetition] = []
  
  struct Input {
    let viewDidLoad: PublishSubject<Date>
    let didToggleFixtures: PublishRelay<FixtureGroupByCompetition>
  }
  
  struct Output {
    let fixtures: PublishSubject<[FixtureGroupByCompetition]>
  }
  
  private let fetchFixtureByFollowedCompetitionUseCase = FetchFixturesByFollowedCompetitionUseCase()
  private let disposeBag = DisposeBag()

  func transform(_ input: Input) -> Output {
    
    input.viewDidLoad
      .flatMap { [weak self] value -> Single<[FixtureGroupByCompetition]> in
        guard let self else { return Single.error(MatchesError.unknownError) }
        return fetchFixtureByFollowedCompetitionUseCase.execute(date: value)
      }
      .subscribe(with: self) { owner, value in
        owner.matches.onNext(value)
        owner.matchesData = value
      }
      .disposed(by: disposeBag)

    input.didToggleFixtures
      .subscribe(with: self) { owner, value in
        var fixtures = owner.matchesData
        if let index = fixtures.firstIndex(where: {
          $0 == value
        }) {
          fixtures[index].isExpanded.toggle()
          owner.matches.onNext(fixtures)
        }
      }
      .disposed(by: disposeBag)
    
    return Output(fixtures: matches)
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
    case unknownError
  }
}
