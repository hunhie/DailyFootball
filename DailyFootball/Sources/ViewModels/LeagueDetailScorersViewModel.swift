//
//  LeagueDetailScorersViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/26.
//

import Foundation
import RxSwift
import RxCocoa

final class LeagueDetailScorersViewModel: ViewModelTransformable {
  struct Input {
    let viewDidLoad: PublishSubject<(season: Int, id: Int)>
  }
  
  struct Output {
    let scorers: PublishSubject<[Scorer]>
  }
  
  private let fetchLeagueScorersUseCase = FetchLeagueScorersUseCase()
  private let disposeBag = DisposeBag()
  
  func transform(_ input: Input) -> Output {
    let scorers = PublishSubject<[Scorer]>()
    
    input.viewDidLoad
      .flatMap { [weak self] value -> Single<[Scorer]> in
        guard let self else { return Single.error(LeagueDetailScorersViewError.serverError) }
        return fetchLeagueScorersUseCase.execute(season: value.season, id: value.id)
      }
      .subscribe(with: self) { owner, value in
        scorers.onNext(value)
      } onError: { owner, error in
        scorers.onError(error)
      }
      .disposed(by: disposeBag)

    return Output(scorers: scorers)
  }
}


extension LeagueDetailScorersViewModel {
  enum LeagueDetailScorersViewError: Error {
    case dataEmpty
    case networkError
    case serverError
  }
}
