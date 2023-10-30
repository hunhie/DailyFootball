//
//  LocalizedStrings.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/09/28.
//

import Foundation

protocol Localizable {
  var localizedValue: String { get }
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
  var localizedValue: String {
    return NSLocalizedString(rawValue, comment: "")
  }
}

enum LocalizedStrings {
  enum Common: String, Localizable {
    case ok = "common_ok"
    case cancel = "common_cancel"
    case dataEmpty = "common_data_empty"
    case networkErrorTitle = "common_network_error_title"
    case networkErrorContent = "common_network_error_content"
    case serverErrorTitle = "common_server_error_title"
    case serverErrorContent = "common_server_error_content"
  }
  
  enum TabBar {
    enum Leagues: String, Localizable {
      case title = "tab_leagues_title"
      case searchbarPlaceholder = "searchbar_placeholder"
      case followButton = "button_state_follow"
      case followingButton = "button_state_following"
      case sectionFavorite = "section_favorite"
      case sectionAllCompetition = "section_allCompetition"
      case editingButton = "button_state_editing"
      case doneButton = "button_state_done"
      case noFollowCompetition = "leagues_no_follow_competition"
    }
    
    enum Matches: String, Localizable {
      case title = "tab_matches_title"
      case noFixtureAvailable = "matches_fixture_available"
      case toBeDefined = "matches_fixtureInfo_TBD"
      case postponed = "matches_fixtureInfo_PPD"
      case cancelled = "matches_fixtureInfo_CAN"
      case abandoned = "matches_fixtureInfo_ABD"
      case notPlayed = "matches_fixtureInfo_NPL"
    }
    
    
    enum Following: String, Localizable {
      case title = "tab_following_title"
    }
    
    enum News: String, Localizable {
      case title = "tab_news_title"
    }
    
    enum More: String, Localizable {
      case title = "tab_more_title"
    }
  }
  
  enum Leagues {
    enum LeagueDetailTab: String, Localizable, CaseIterable {
      case standings = "league_detail_tab_standings"
      case scorers = "league_detail_tab_scorers"
      
      enum standingsHeader: String, Localizable {
        case rank = "standings_header_title"
        case mp = "standings_header_mp"
        case win = "standings_header_win"
        case draw = "standings_header_draw"
        case lose = "standings_header_lose"
        case goalDiff = "standings_header_goaldiff"
        case points = "standings_header_points"
      }
      
      enum scorersHeader: String, Localizable {
        case rank = "scorers_header_rank"
        case goals = "scorers_header_goals"
      }
    }
  }
  
  enum More {
    enum SettingSection: String, Localizable, CaseIterable {
      case system = "more_system"
      case support = "more_support"
      case info = "more_info"
    }
    
    enum SettingItem: String, Localizable, CaseIterable {
      case theme = "more_theme"
      case contact = "more_contact"
      case license = "more_license"
      case privacy = "more_privacy"
      case version = "more_version"
    }
  }
  
  enum Matches {
    enum MatchesTab: String, Localizable, CaseIterable {
      case yesterday = "matches_tab_yesterday"
      case today = "matches_tab_today"
      case tomorrow = "matches_tab_tomorrow"
    }
  }
  
}
