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
  
  
  //  private func fetchCompetitionGroups() {
  //    fetchCompetitionGroupsUseCase.execute { [weak self] result in
  //      guard let self else { return }
  //      switch result {
  //      case .success(let response):
  //
  //      case .failure(let error):
  //        self.state.value = .error(error)
  //      }
  //    }
  //  }
  //
  // MARK: - Subjects
  private var followedCompetitions = BehaviorRelay<[Competition]>(value: [])
  private var competitionGroups = BehaviorRelay<[CompetitionGroupByCountry]>(value: [])
  
  // MARK: - Relay
  var isEditMode = BehaviorRelay(value: false)
  var followEvent = PublishRelay<Competition>()
  var unfollowEvent = PublishRelay<Competition>()
  var didToggleCompeitionGroup = PublishRelay<CompetitionGroupByCountry>()
  var didToggleEditMode = PublishRelay<Void>()
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  
  // MARK: - UseCases
  private lazy var fetchCompetitionGroupsUseCase = FetchAllCompetitionGroupedByCountryUseCase()
  private lazy var fetchFollowedCompetitionsUseCase = FetchFollowedCompetitionsUseCase()
  private lazy var reorderFollowedCompetitionsUseCase = ReorderFollowedCompetitionsUseCase()
  private lazy var followCompetitionUseCase = FollowCompetitionUseCase()
  private lazy var unfollowCompetitionUseCase = UnfollowCompetitionUseCase()
  
  init() {
    didToggleEditMode
      .subscribe(with: self) { owner, _ in
        let value = owner.isEditMode.value
        owner.isEditMode.accept(!value)
      }
      .disposed(by: disposeBag)
    
    didToggleCompeitionGroup
      .subscribe(with: self) { owner, value in
        var groups = owner.competitionGroups.value
        if let index = groups.firstIndex(where: { $0.country.name == value.country.name }) {
          groups[index].isExpanded.toggle()
          let groups = groups
          owner.competitionGroups.accept(groups)
        }
      }
      .disposed(by: disposeBag)
    
    followEvent
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
//        owner.updateFollowedCompetitions(value.1)
      }
      .disposed(by: disposeBag)
    
    unfollowEvent
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
        owner.updateCompetitionGroups(value.0)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Transform
  
  struct Input {
    let viewDidLoad: PublishSubject<Void>
  }
  
  struct Output {
    let followedCompetitions: BehaviorRelay<[Competition]>
    let competitionGroups: BehaviorRelay<[CompetitionGroupByCountry]>
    let isEditingMode: BehaviorRelay<Bool>
    let followEvent: PublishRelay<Competition>
    let unfollowEvent: PublishRelay<Competition>
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
    
    return Output(
      followedCompetitions: followedCompetitions,
      competitionGroups: competitionGroups,
      isEditingMode: isEditMode,
      followEvent: followEvent,
      unfollowEvent: unfollowEvent
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
  
  //  var followedCompetitions: [Competition] = []
  //  var competitionGroups: [CompetitionGroupByCountry] = []
  //
  //  var filteredFollowedCompetitions: [Competition] = []
  //  var filteredCompetitionGroups: [CompetitionGroupByCountry] = []
  //
  //  var isEditingFollowingCompetition: Bool = false
  //  var isSearching: Bool = false
  //
  //  private let fetchCompetitionGroupsUseCase: FetchAllCompetitionGroupedByCountryUseCase
  //  private let fetchFollowedCompetitionsUseCase: FetchFollowedCompetitionsUseCase
  //  private let reorderFollowedCompetitionsUseCase: ReorderFollowedCompetitionsUseCase
  //  private let followCompetitionUseCase: FollowCompetitionUseCase
  //  private let unfollowCompetitionUseCase: UnfollowCompetitionUseCase
  //
  //  var state: Observable<State> = Observable(.idle)
  //
  //  init() {
  //    self.fetchCompetitionGroupsUseCase = FetchAllCompetitionGroupedByCountryUseCase()
  //    self.fetchFollowedCompetitionsUseCase = FetchFollowedCompetitionsUseCase()
  //    self.reorderFollowedCompetitionsUseCase = ReorderFollowedCompetitionsUseCase()
  //    self.followCompetitionUseCase = FollowCompetitionUseCase()
  //    self.unfollowCompetitionUseCase = UnfollowCompetitionUseCase()
  //  }
  //
  //  func handle(action: Action) {
  //    switch action {
  //    case .fetchCompetitionGroups:
  //      fetchCompetitionGroups()
  //    case .fetchFollowedCompetitions:
  //      fetchFollowedCompetitions()
  //    case .followCompetition(let competition):
  //      followCompetition(competition: competition)
  //    case .unfollowCompetition(let competition):
  //      unfollowCompetition(competition: competition)
  //    case .toggleCompetitionGroupDetail(let competitionGroup):
  //      toggleDetail(for: competitionGroup)
  //    case .searchCompetition(let query):
  //      searchCompetition(with: query)
  //    case .reorderCompetition(from: let from, to: let to):
  //      reorderFollowedCompetitions(from: from, to: to)
  //    case .tapEditOnFollowingSection:
  //      self.isEditingFollowingCompetition.toggle()
  //      state.value = .followingSectionEditTapped(isEditingFollowingCompetition: isEditingFollowingCompetition)
  //    case .showIndicator:
  //      state.value = .loading
  //    }
  //  }
  //
  //  func handleSearchInput(isActive: Bool, searchText: String?) {
  //    if isActive, let query = searchText, !query.isEmpty {
  //      isSearching = true
  //      handle(action: .searchCompetition(query))
  //    } else {
  //      isSearching = false
  //      handle(action: .fetchFollowedCompetitions)
  //      reloadCompetitions()
  //    }
  //  }
  //
  //  private func fetchFollowedCompetitions(animated: Bool = false) {
  //    fetchFollowedCompetitionsUseCase.execute { [weak self] result in
  //      guard let self else { return }
  //      switch result {
  //      case .success(let response):
  //        self.state.value = .followedCompetitionsLoad(response, animated: animated)
  //        self.followedCompetitions = response
  //      case .failure(let error):
  //        self.state.value = .error(error)
  //      }
  //    }
  //  }
  //
  //  private func fetchCompetitionGroups() {
  //    fetchCompetitionGroupsUseCase.execute { [weak self] result in
  //      guard let self else { return }
  //      switch result {
  //      case .success(let response):
  //        self.state.value = .competitionsLoaded(response)
  //        self.competitionGroups = response
  //      case .failure(let error):
  //        self.state.value = .error(error)
  //      }
  //    }
  //  }
  //
  //  private func followCompetition(competition: Competition) {
  //    do {
  //      try followCompetitionUseCase.execute(competition: competition)
  //      fetchFollowedCompetitions(animated: true)
  //      updateFollowStatus(for: competition, in: &competitionGroups, to: true)
  //      reloadCompetitions()
  //    } catch {
  //      state.value = .error(error)
  //    }
  //  }
  //
  //  private func unfollowCompetition(competition: Competition) {
  //    do {
  //      try unfollowCompetitionUseCase.execute(competition: competition)
  //      fetchFollowedCompetitions(animated: true)
  //      updateFollowStatus(for: competition, in: &competitionGroups, to: false)
  //      reloadCompetitions()
  //    } catch {
  //      state.value = .error(error)
  //    }
  //  }
  //
  //  private func updateFollowStatus(for targetCompetition: Competition, in competitionGroups: inout [CompetitionGroupByCountry], to isFollowed: Bool) {
  //    for (groupIndex, group) in competitionGroups.enumerated() {
  //      if let compIndex = group.competitions.firstIndex(where: { $0.id == targetCompetition.id }) {
  //        var competitionsInGroup = group.competitions
  //        competitionsInGroup[compIndex].isFollowed = isFollowed
  //        competitionGroups[groupIndex].competitions = competitionsInGroup
  //      }
  //    }
  //  }
  //
  //  private func toggleDetail(for competitionGroup: CompetitionGroupByCountry) {
  //
  //  }
  //}
  //
  //  private func searchCompetition(with searchText: String) {
  //    let searchText = searchText.lowercased()
  //
  //    filteredCompetitionGroups = competitionGroups.compactMap { group -> CompetitionGroupByCountry? in
  //      var modifiedGroup = group
  //      modifiedGroup.isExpanded = true
  //
  //      if group.country.name.lowercased().contains(searchText) {
  //        return modifiedGroup
  //      } else {
  //        let filteredCompetitions = group.competitions.filter {
  //          $0.info.name.lowercased().contains(searchText)
  //        }
  //
  //        guard !filteredCompetitions.isEmpty else { return nil }
  //        modifiedGroup.competitions = filteredCompetitions
  //        return modifiedGroup
  //      }
  //    }
  //
  //    filteredFollowedCompetitions = followedCompetitions.filter {
  //      let title = $0.info.name.lowercased()
  //      let country = $0.country.name.lowercased()
  //      return title.contains(searchText) || country.contains(searchText)
  //    }
  //
  //    state.value = .searchResultLoaded(filteredCompetitionGroups: filteredCompetitionGroups, filteredFollowedCompetitions: filteredFollowedCompetitions)
  //  }
  //
  //  private func reorderFollowedCompetitions(from initialPosition: IndexPath, to targetPosition: IndexPath) {
  //    guard initialPosition.row < followedCompetitions.count, targetPosition.row < followedCompetitions.count else { return }
  //    var reorderedCompetitions = followedCompetitions
  //    let selectedCompetition = reorderedCompetitions[initialPosition.row]
  //    reorderedCompetitions.remove(at: initialPosition.row)
  //    reorderedCompetitions.insert(selectedCompetition, at: targetPosition.row)
  //
  //    do {
  //      try reorderFollowedCompetitionsUseCase.execute(with: reorderedCompetitions)
  //      followedCompetitions = reorderedCompetitions
  //      state.value = .reorderedFollowedCompetitions(from: initialPosition, to: targetPosition)
  //    } catch {
  //      state.value = .error(error);
  //    }
  //  }
  //
  //  private func reloadCompetitions() {
  //    state.value = .competitionsLoaded(self.competitionGroups)
  //  }
  //
  //}
  //
  ////MARK: - Action & State
  //extension LeaguesViewModel {
  //  enum Action {
  //    case fetchCompetitionGroups
  //    case fetchFollowedCompetitions
  //    case followCompetition(Competition)
  //    case unfollowCompetition(Competition)
  //    case toggleCompetitionGroupDetail(CompetitionGroupByCountry)
  //    case reorderCompetition(from: IndexPath, to: IndexPath)
  //    case searchCompetition(String)
  //    case tapEditOnFollowingSection
  //    case showIndicator
  //  }
  //
  //  enum State {
  //    case idle
  //    case loading
  //    case competitionsLoaded([CompetitionGroupByCountry])
  //    case followedCompetitionsLoad([Competition], animated: Bool)
  //    case followedSuccess(Competition)
  //    case unfollowedSuccess(Competition)
  //    case competitionGroupExpansionToggled([CompetitionGroupByCountry])
  //    case searchResultLoaded(filteredCompetitionGroups: [CompetitionGroupByCountry], filteredFollowedCompetitions: [Competition])
  //    case reorderedFollowedCompetitions(from: IndexPath, to: IndexPath)
  //    case followingSectionEditTapped(isEditingFollowingCompetition: Bool)
  //    case error(Error)
  //  }
}
