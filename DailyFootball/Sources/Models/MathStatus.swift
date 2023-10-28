//
//  MathStatus.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

enum MatchStatus {
  case scheduled(ScheduledStatus)  // 예정된 경기
  case inPlay(InPlayStatus)        // 경기 진행 중
  case finished(FinishedStatus)    // 경기 종료
  case postponed                   // 연기됨
  case cancelled                   // 취소됨
  case abandoned                   // 중단됨
  case notPlayed(NotPlayedStatus)  // 진행되지 않음
  
  enum ScheduledStatus {
    case toBeDefined       // 일정 미정
    case notStarted        // 아직 시작되지 않음
  }
  
  enum InPlayStatus {
    case firstHalf          // 1회전
    case halftime           // 중간 휴식
    case secondHalf         // 2회전
    case extraTime          // 연장전
    case breakTime          // 연장전 휴식
    case penaltyInProgress  // 페널티 중
    case suspended          // 중단됨 (재개 예정)
    case interrupted        // 잠시 중단됨
    case live               // 실시간 진행 중 (세부 상태 미정)
  }
  
  enum FinishedStatus {
    case regularTime            // 정규 시간 종료
    case afterExtraTime         // 연장전 후 종료
    case afterPenaltyShootout   // 페널티 슛아웃 후 종료
  }
  
  enum NotPlayedStatus {
    case technicalLoss  // 기술적 패배
    case walkOver       // 상대 불참으로 승리
  }
}
