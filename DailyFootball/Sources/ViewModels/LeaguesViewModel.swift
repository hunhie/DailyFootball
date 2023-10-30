//
//  LeaguesViewModel.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import Foundation

final class LeaguesViewModel {
  
  var followedCompetitions: [Competition] = []
  var competitionGroups: [CompetitionGroupByCountry] = []
  
  var filteredFollowedCompetitions: [Competition] = []
  var filteredCompetitionGroups: [CompetitionGroupByCountry] = []
  
  var isEditingFollowingCompetition: Bool = false
  var isSearching: Bool = false
  
  private let fetchCompetitionGroupsUseCase: FetchAllCompetitionGroupedByCountryUseCase
  private let fetchFollowedCompetitionsUseCase: FetchFollowedCompetitionsUseCase
  private let reorderFollowedCompetitionsUseCase: ReorderFollowedCompetitionsUseCase
  private let followCompetitionUseCase: FollowCompetitionUseCase
  private let unfollowCompetitionUseCase: UnfollowCompetitionUseCase
  
  var state: Observable<State> = Observable(.idle)
  
  init() {
    self.fetchCompetitionGroupsUseCase = FetchAllCompetitionGroupedByCountryUseCase()
    self.fetchFollowedCompetitionsUseCase = FetchFollowedCompetitionsUseCase()
    self.reorderFollowedCompetitionsUseCase = ReorderFollowedCompetitionsUseCase()
    self.followCompetitionUseCase = FollowCompetitionUseCase()
    self.unfollowCompetitionUseCase = UnfollowCompetitionUseCase()
  }
  
  func handle(action: Action) {
    switch action {
    case .fetchCompetitionGroups:
      fetchCompetitionGroups()
    case .fetchFollowedCompetitions:
      fetchFollowedCompetitions()
    case .followCompetition(let competition):
      followCompetition(competition: competition)
    case .unfollowCompetition(let competition):
      unfollowCompetition(competition: competition)
    case .toggleCompetitionGroupDetail(let competitionGroup):
      toggleDetail(for: competitionGroup)
    case .searchCompetition(let query):
      searchCompetition(with: query)
    case .reorderCompetition(from: let from, to: let to):
      reorderFollowedCompetitions(from: from, to: to)
    case .tapEditOnFollowingSection:
      self.isEditingFollowingCompetition.toggle()
      state.value = .followingSectionEditTapped(isEditingFollowingCompetition: isEditingFollowingCompetition)
    case .showIndicator:
      state.value = .loading
    }
  }
  
  func handleSearchInput(isActive: Bool, searchText: String?) {
    if isActive, let query = searchText, !query.isEmpty {
      isSearching = true
      handle(action: .searchCompetition(query))
    } else {
      isSearching = false
      handle(action: .fetchFollowedCompetitions)
      reloadCompetitions()
    }
  }
  
  private func fetchFollowedCompetitions(animated: Bool = false) {
    fetchFollowedCompetitionsUseCase.execute { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let response):
        self.state.value = .followedCompetitionsLoad(response, animated: animated)
        self.followedCompetitions = response
      case .failure(let error):
        self.state.value = .error(error)
      }
    }
  }
  
  private func fetchCompetitionGroups() {
    fetchCompetitionGroupsUseCase.execute { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let response):
        self.state.value = .competitionsLoaded(response)
        self.competitionGroups = response
      case .failure(let error):
        self.state.value = .error(error)
      }
    }
  }
  
  private func followCompetition(competition: Competition) {
    do {
      try followCompetitionUseCase.execute(competition: competition)
      fetchFollowedCompetitions(animated: true)
      updateFollowStatus(for: competition, in: &competitionGroups, to: true)
      reloadCompetitions()
    } catch {
      state.value = .error(error)
    }
  }
  
  private func unfollowCompetition(competition: Competition) {
    do {
      try unfollowCompetitionUseCase.execute(competition: competition)
      fetchFollowedCompetitions(animated: true)
      updateFollowStatus(for: competition, in: &competitionGroups, to: false)
      reloadCompetitions()
    } catch {
      state.value = .error(error)
    }
  }
  
  private func updateFollowStatus(for targetCompetition: Competition, in competitionGroups: inout [CompetitionGroupByCountry], to isFollowed: Bool) {
    for (groupIndex, group) in competitionGroups.enumerated() {
      if let compIndex = group.competitions.firstIndex(where: { $0.id == targetCompetition.id }) {
        var competitionsInGroup = group.competitions
        competitionsInGroup[compIndex].isFollowed = isFollowed
        competitionGroups[groupIndex].competitions = competitionsInGroup
      }
    }
  }
  
  private func toggleDetail(for competitionGroup: CompetitionGroupByCountry) {
    if isSearching {
      if let index = filteredCompetitionGroups.firstIndex(where: { $0.country.name == competitionGroup.country.name }) {
        filteredCompetitionGroups[index].isExpanded.toggle()
        state.value = .competitionGroupExpansionToggled(self.filteredCompetitionGroups)
      }
    } else {
      if let index = competitionGroups.firstIndex(where: { $0.country.name == competitionGroup.country.name }) {
        competitionGroups[index].isExpanded.toggle()
        state.value = .competitionGroupExpansionToggled(self.competitionGroups)
      }
    }
  }
  
  private func searchCompetition(with searchText: String) {
    let searchText = searchText.lowercased()
    
    filteredCompetitionGroups = competitionGroups.compactMap { group -> CompetitionGroupByCountry? in
      var modifiedGroup = group
      modifiedGroup.isExpanded = true
      
      if group.country.name.lowercased().contains(searchText) {
        return modifiedGroup
      } else {
        let filteredCompetitions = group.competitions.filter {
          $0.info.name.lowercased().contains(searchText)
        }
        
        guard !filteredCompetitions.isEmpty else { return nil }
        modifiedGroup.competitions = filteredCompetitions
        return modifiedGroup
      }
    }
    
    filteredFollowedCompetitions = followedCompetitions.filter {
      let title = $0.info.name.lowercased()
      let country = $0.country.name.lowercased()
      return title.contains(searchText) || country.contains(searchText)
    }
    
    state.value = .searchResultLoaded(filteredCompetitionGroups: filteredCompetitionGroups, filteredFollowedCompetitions: filteredFollowedCompetitions)
  }
  
  private func reorderFollowedCompetitions(from initialPosition: IndexPath, to targetPosition: IndexPath) {
    guard initialPosition.row < followedCompetitions.count, targetPosition.row < followedCompetitions.count else { return }
    var reorderedCompetitions = followedCompetitions
    let selectedCompetition = reorderedCompetitions[initialPosition.row]
    reorderedCompetitions.remove(at: initialPosition.row)
    reorderedCompetitions.insert(selectedCompetition, at: targetPosition.row)
    
    do {
      try reorderFollowedCompetitionsUseCase.execute(with: reorderedCompetitions)
      followedCompetitions = reorderedCompetitions
      state.value = .reorderedFollowedCompetitions(from: initialPosition, to: targetPosition)
    } catch {
      state.value = .error(error);
    }
  }
  
  private func reloadCompetitions() {
    state.value = .competitionsLoaded(self.competitionGroups)
  }
  
}

//MARK: - Action & State
extension LeaguesViewModel {
  enum Action {
    case fetchCompetitionGroups
    case fetchFollowedCompetitions
    case followCompetition(Competition)
    case unfollowCompetition(Competition)
    case toggleCompetitionGroupDetail(CompetitionGroupByCountry)
    case reorderCompetition(from: IndexPath, to: IndexPath)
    case searchCompetition(String)
    case tapEditOnFollowingSection
    case showIndicator
  }
  
  enum State {
    case idle
    case loading
    case competitionsLoaded([CompetitionGroupByCountry])
    case followedCompetitionsLoad([Competition], animated: Bool)
    case followedSuccess(Competition)
    case unfollowedSuccess(Competition)
    case competitionGroupExpansionToggled([CompetitionGroupByCountry])
    case searchResultLoaded(filteredCompetitionGroups: [CompetitionGroupByCountry], filteredFollowedCompetitions: [Competition])
    case reorderedFollowedCompetitions(from: IndexPath, to: IndexPath)
    case followingSectionEditTapped(isEditingFollowingCompetition: Bool)
    case error(Error)
  }
}
