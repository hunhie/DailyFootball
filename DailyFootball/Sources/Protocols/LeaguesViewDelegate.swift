//
//  LeaguesViewDelegate.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/15.
//

import Foundation

protocol LeaguesViewDelegate: AnyObject {
  func didFollow(competition: Competition)
  func didUnfollow(competition: Competition)
  func didTapCompetitionGroup(competitionGroup: CompetitionGroup)
  func didTapCompetition(competition: Competition)
}
