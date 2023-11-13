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
  private let followedCompetitions = BehaviorRelay<(data: [Competition], animated: Bool)>(value: ([], true))
  private let competitionGroups = BehaviorRelay<(data: [CompetitionGroupByCountry], animated: Bool)>(value: ([], true))
  
  // MARK: - Relay
  let isEditMode = BehaviorRelay(value: false)
  let followEvent = PublishRelay<Competition>()
  let unfollowEvent = PublishRelay<Competition>()
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private var followedCompetitionsData: [Competition] = []
  private var competitionGroupsData: [CompetitionGroupByCountry] = []
  
  // MARK: - UseCases
  private lazy var fetchCompetitionGroupsUseCase = FetchAllCompetitionGroupedByCountryUseCase()
  private lazy var fetchFollowedCompetitionsUseCase = FetchFollowedCompetitionsUseCase()
  private lazy var reorderFollowedCompetitionsUseCase = ReorderFollowedCompetitionsUseCase()
  private lazy var followCompetitionUseCase = FollowCompetitionUseCase()
  private lazy var unfollowCompetitionUseCase = UnfollowCompetitionUseCase()
  
  // MARK: - Transform
  
  struct Input {
    let viewDidLoad: PublishSubject<Void>
    let didToggleCompeitionGroup: PublishRelay<CompetitionGroupByCountry>
    let didToggleEditMode: PublishRelay<Void>
    let reorderEvent: PublishRelay<(from: IndexPath, to: IndexPath)>
  }
  
  struct Output {
    let followedCompetitions: BehaviorRelay<(data: [Competition], animated: Bool)>
    let competitionGroups: BehaviorRelay<(data: [CompetitionGroupByCountry], animated: Bool)>
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
      .throttle(.milliseconds(650), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, value in
        var groups = owner.competitionGroups.value
        if let index = groups.0.firstIndex(where: { $0.country.name == value.country.name }) {
          groups.0[index].isExpanded.toggle()
          let groups = groups
          owner.competitionGroups.accept(groups)
        }
      }
      .disposed(by: disposeBag)
    
    followEvent
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
    
    unfollowEvent
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
      if let index = lastetData.data.firstIndex(where: { $0.country == newGroup.country }) {
        newData[index].isExpanded = lastetData.data[index].isExpanded
      }
    }
    
    competitionGroups.accept((newData, true))
    competitionGroupsData = newData
  }
  
  private func updateFollowedCompetitions(_ data: [Competition]) {
    followedCompetitions.accept((data, true))
    followedCompetitionsData = data
  }
  
  private func reorderFollowedCompetitions(from initialPosition: IndexPath, to targetPosition: IndexPath) {
    guard initialPosition.row < followedCompetitions.value.data.count,
          targetPosition.row < followedCompetitions.value.data.count else { return }
    
    var reorderedCompetitions = followedCompetitions.value
    let selectedCompetition = reorderedCompetitions.data.remove(at: initialPosition.row)
    reorderedCompetitions.data.insert(selectedCompetition, at: targetPosition.row)
    
    reorderFollowedCompetitionsUseCase.execute(with: reorderedCompetitions.data)
      .subscribe(with: self, onCompleted: { owner in
        owner.followedCompetitions.accept(reorderedCompetitions)
      })
      .disposed(by: disposeBag)
  }
  
  func searchCompetition(with searchText: String) {
    let searchText = searchText.lowercased()
    
    let filteredCompetitionGroups = competitionGroupsData
      .map { group -> CompetitionGroupByCountry in
        var modifiedGroup = group
        modifiedGroup.isExpanded = true
        
        if group.country.name.lowercased().contains(searchText) {
          return modifiedGroup
        } else {
          let filteredCompetitions = group.competitions.filter {
            $0.info.name.lowercased().contains(searchText)
          }
          
          modifiedGroup.competitions = filteredCompetitions
          return modifiedGroup
        }
      }
      .filter { !$0.competitions.isEmpty || $0.country.name.lowercased().contains(searchText) }
    
    let filteredFollowedCompetitions = followedCompetitionsData
      .filter {
        let title = $0.info.name.lowercased()
        let country = $0.country.name.lowercased()
        return title.contains(searchText) || country.contains(searchText)
      }
    
    followedCompetitions.accept((filteredFollowedCompetitions, false))
    competitionGroups.accept((filteredCompetitionGroups, false))
  }
}
