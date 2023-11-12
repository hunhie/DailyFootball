//
//  LeaguesViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import Foundation
import RxSwift
import RxCocoa

enum LeagueViewError: Error {
  case dataLoadFailed
}

final class LeaguesViewModel: ViewModelTransformable {
  // MARK: - Subjects
  private var followedCompetitions = BehaviorRelay<[Competition]>(value: [])
  private var competitionGroups = BehaviorRelay<[CompetitionGroupByCountry]>(value: [])
  
  // MARK: - Relay
  var isEditMode = BehaviorRelay(value: false)
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  
  // MARK: - UseCases
  private lazy var fetchCompetitionGroupsUseCase = FetchAllCompetitionGroupedByCountryUseCase()
  private lazy var fetchFollowedCompetitionsUseCase = FetchFollowedCompetitionsUseCase()
  private lazy var reorderFollowedCompetitionsUseCase = ReorderFollowedCompetitionsUseCase()
  private lazy var followCompetitionUseCase = FollowCompetitionUseCase()
  private lazy var unfollowCompetitionUseCase = UnfollowCompetitionUseCase()
  
  // MARK: - Transform
  
  struct Input {
    let viewDidLoad: PublishSubject<Void>
    let followEvent: PublishRelay<Competition>
    let unfollowEvent: PublishRelay<Competition>
    let didToggleCompeitionGroup: PublishRelay<CompetitionGroupByCountry>
    let didToggleEditMode: PublishRelay<Void>
    let reorderEvent: PublishRelay<(from: IndexPath, to: IndexPath)>
  }
  
  struct Output {
    let followedCompetitions: BehaviorRelay<[Competition]>
    let competitionGroups: BehaviorRelay<[CompetitionGroupByCountry]>
    let isEditingMode: BehaviorRelay<Bool>
  }
  
  func transform(_ input: Input) -> Output {
    input.viewDidLoad
      .flatMap { [weak self] _ -> Single<([CompetitionGroupByCountry], [Competition])> in
        guard let self else { return Single.error(LeagueViewError.dataLoadFailed) }
        return Single.zip(
          self.fetchCompetitionGroupsUseCase.execute(),
          self.fetchFollowedCompetitionsUseCase.execute()
        )
      }
      .subscribe(with: self) { owner, value in
        owner.updateCompetitionGroups(value.0)
        owner.updateFollowedCompetitions(value.1)
      }
      .disposed(by: disposeBag)
    
    input.didToggleEditMode
      .subscribe(with: self) { owner, _ in
        let value = owner.isEditMode.value
        owner.isEditMode.accept(!value)
      }
      .disposed(by: disposeBag)
    
    input.didToggleCompeitionGroup
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, value in
        var groups = owner.competitionGroups.value
        if let index = groups.firstIndex(where: { $0.country.name == value.country.name }) {
          groups[index].isExpanded.toggle()
          let groups = groups
          owner.competitionGroups.accept(groups)
        }
      }
      .disposed(by: disposeBag)
    
    input.followEvent
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .flatMap { [weak self] value -> Single<([CompetitionGroupByCountry], [Competition])> in
        guard let self else { return Single.error(LeagueViewError.dataLoadFailed) }
        
        return self.followCompetitionUseCase.execute(competition: value)
          .andThen(
            Single.zip(
              fetchCompetitionGroupsUseCase.execute(),
              fetchFollowedCompetitionsUseCase.execute()
            )
          )
      }
      .subscribe(with: self) { owner, value in
        owner.updateCompetitionGroups(value.0)
        owner.updateFollowedCompetitions(value.1)
      }
      .disposed(by: disposeBag)
    
    input.unfollowEvent
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .flatMap { [weak self] value -> Single<([CompetitionGroupByCountry], [Competition])> in
        guard let self else { return Single.error(LeagueViewError.dataLoadFailed) }
        
        return self.unfollowCompetitionUseCase.execute(competition: value)
          .andThen(
            Single.zip(
              fetchCompetitionGroupsUseCase.execute(),
              fetchFollowedCompetitionsUseCase.execute()
            )
          )
      }
      .subscribe(with: self) { owner, value in
        owner.updateFollowedCompetitions(value.1)
        owner.updateCompetitionGroups(value.0)
      }
      .disposed(by: disposeBag)
    
    input.reorderEvent
      .subscribe(with: self) { owner, value in
        owner.reorderFollowedCompetitions(from: value.from, to: value.to)
      }
      .disposed(by: disposeBag)
    
    return Output(
      followedCompetitions: followedCompetitions,
      competitionGroups: competitionGroups,
      isEditingMode: isEditMode
    )
  }
  
  private func updateCompetitionGroups(_ data: [CompetitionGroupByCountry]) {
    let lastetData = competitionGroups.value
    var newData = data
    
    newData.forEach { newGroup in
      if let index = lastetData.firstIndex(where: { $0.country == newGroup.country }) {
        newData[index].isExpanded = lastetData[index].isExpanded
      }
    }
    
    competitionGroups.accept(newData)
  }
  
  private func updateFollowedCompetitions(_ data: [Competition]) {
    self.followedCompetitions.accept(data)
  }
  
  private func reorderFollowedCompetitions(from initialPosition: IndexPath, to targetPosition: IndexPath) {
    guard initialPosition.row < followedCompetitions.value.count,
          targetPosition.row < followedCompetitions.value.count else { return }
    
    var reorderedCompetitions = followedCompetitions.value
    let selectedCompetition = reorderedCompetitions.remove(at: initialPosition.row)
    reorderedCompetitions.insert(selectedCompetition, at: targetPosition.row)
    
    reorderFollowedCompetitionsUseCase.execute(with: reorderedCompetitions)
      .subscribe(with: self, onCompleted: { owner in
        owner.followedCompetitions.accept(reorderedCompetitions)
      })
      .disposed(by: disposeBag)
  }
}
