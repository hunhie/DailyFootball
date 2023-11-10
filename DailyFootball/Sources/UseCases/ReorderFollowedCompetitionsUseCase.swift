//
//  ReorderFollowedCompetitionsUseCase.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/19.
//

import Foundation
import RxSwift

struct ReorderFollowedCompetitionsUseCase {
  private let userCompetitionFollowsRepo = UserCompetitionFollowsRepository()
  let disposeBag = DisposeBag()
  
  func execute(with reorderedFollowedCompetitions: [Competition]) -> PublishSubject<Void> {
    let subject = PublishSubject<Void>()
    
      let response = userCompetitionFollowsRepo.reorderFollowedCompetitions(competitions: reorderedFollowedCompetitions)
      response.subscribe { _ in
        subject.onError(ReorderFollowedCompetitionsError.reorderFailed)
      } onCompleted: {
        subject.onCompleted()
      }
      .disposed(by: disposeBag)
    
    return subject
  }
}

extension ReorderFollowedCompetitionsUseCase {
  enum ReorderFollowedCompetitionsError: Error {
    case reorderFailed
  }
}
