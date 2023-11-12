//
//  LeagueDetailStandingsViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LeagueDetailStandingsViewModel: ViewModelTransformable {
  struct Input {
    let viewDidLoad: PublishSubject<(season: Int, id: Int)>
  }
  
  struct Output {
    let standings: PublishSubject<[Standing]>
  }
  
  private let fetchLeagueStandingsUseCase = FetchLeagueStandingsUseCase()
  private let disposeBag = DisposeBag()
  
  func transform(_ input: Input) -> Output {
    let standings = PublishSubject<[Standing]>()
    
    input.viewDidLoad
      .flatMap { [weak self] value -> Single<[Standing]> in
        guard let self else { return Single.error(LeagueDetailStandingsViewError.serverError) }
        return fetchLeagueStandingsUseCase.execute(season: value.season, id: value.id)
      }
      .subscribe(with: self, onNext: { owner, value in
        standings.onNext(value)
      }, onError: { owner, error in
        standings.onError(error)
      })
      .disposed(by: disposeBag)
    
    return Output(standings: standings)
  }
  
//  var state: Observable<State> = Observable(.idle)
//  
//  func handle(action: Action) {
//    switch action {
//    case .fetchStandings(let season, let id):
//      fetchStandings(season: season, id: id)
//    }
//  }
//  
//  private func fetchStandings(season: Int, id: Int) {
//    self.state.value = .loading
//    fetchLeagueStandingsUseCase.execute(season: season, id: id) { [weak self] result in
//      guard let self else { return }
//      switch result {
//      case .success(let response):
//        if !response.isEmpty {
//          self.state.value = .loaded
//          self.state.value = .standingsLoaded(response)
//        } else {
//          self.state.value = .error(.dataEmpty)
//        }
//      case .failure(let error):
//        self.state.value = .error(.serverError)
//      }
//    }
//  }
}

extension LeagueDetailStandingsViewModel {
  enum LeagueDetailStandingsViewError: Error {
    case dataEmpty
    case networkError
    case serverError
  }
}
