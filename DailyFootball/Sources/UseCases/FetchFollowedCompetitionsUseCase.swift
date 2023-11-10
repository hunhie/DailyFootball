//
//  FetchFollowedCompetitionsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/12.
//

import Foundation
import RxSwift

struct FetchFollowedCompetitionsUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  private let disposeBag = DisposeBag()
  
  func execute() -> PublishSubject<[Competition]> {
    let subject = PublishSubject<[Competition]>()
    let response =  userCompetitionFollowsRepo.fetchFollowedCompetitions()
    
    response
      .subscribe { value in
        if value.isEmpty {
          subject.onNext([])
        } else {
          do {
            let data = try CompetitionMapper.mapCompetitions(from: value)
            subject.onNext(data)
          } catch {
            subject.onError(FetchFollowedCompetitionsError.dataLoadFailed)
          }
        }
      }
      .disposed(by: disposeBag)
    
    return subject
  }
}

extension FetchFollowedCompetitionsUseCase {
  enum FetchFollowedCompetitionsError: Error {
    case dataLoadFailed
    case dataEmpty
  }
}
