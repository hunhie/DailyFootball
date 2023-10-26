//
//  ScrollViewScrollAnimator.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/22.
//

import UIKit

/// 스크롤 애니메이션을 제어하는 클래스입니다.
final class ScrollViewScrollAnimator {
  
  /// 스크롤 애니메이션 이벤트를 처리하는 클로저 타입입니다.
  typealias Handler = ((_ translation: CGFloat, _ animator: ScrollViewScrollAnimator) -> Void)
  
  /// 스크롤 애니메이션을 제어하기 위한 CADisplayLink 인스턴스
  private var link: CADisplayLink!
  
  /// 스크롤 애니메이션 시작 시간
  private var startTime: TimeInterval!
  
  /// 스크롤 방향 (양수 또는 음수)
  private var sign: CGFloat = 1.0
  
  /// 초기 스크롤 속도
  private var startVelocity: CGPoint = .zero
  
  /// 최대 스크롤 속도
  private var maxVelocity: CGPoint = .init(x: 2000, y: 2000)
  
  /// 스크롤 감속률
  private var deceleration: CGFloat = .zero
  
  /// 스크롤 애니메이션 시작 가속도
  private let minAccelerationThreshold: CGFloat = 50
  
  /// 스크롤 이벤트를 처리하는 클로저
  private var handler: Handler? = nil
  
  /// 클래스 초기화
  init() { }
  
  /// 스크롤 애니메이션을 시작합니다.
  ///
  /// - Parameters:
  ///   - sign: 스크롤 방향 (양수 또는 음수)
  ///   - startVelocity: 초기 스크롤 속도
  ///   - deceleration: 스크롤 감속률
  ///   - handler: 스크롤 이벤트를 처리하는 클로저
  func start(_ sign: CGFloat, _ startVelocity: CGPoint, _ deceleration: CGFloat, _ handler: @escaping Handler) {
    let velocity = CGPoint(x: min(startVelocity.x, maxVelocity.x), y: min(startVelocity.y, maxVelocity.y))
    self.sign = sign
    self.startVelocity = velocity
    self.deceleration = deceleration
    self.handler = handler
    
    self.startTime = CACurrentMediaTime()
    
    link = CADisplayLink(target: self, selector: #selector(linkTicked))
    link!.add(to: .main, forMode: .default)
  }
  
  /// 스크롤 애니메이션을 중지합니다.
  func stop() {
    link?.invalidate()
    link = nil
  }
  
  /// CADisplayLink에 의해 호출되는 메서드로, 스크롤 애니메이션을 업데이트합니다.
  @objc private func linkTicked() {
    // v = u + at AND s = ut + ½at²
    let t = CGFloat(CACurrentMediaTime() - self.startTime)
    let unsignedNextVelocity = abs(startVelocity.y) - deceleration * t
    let unsignedDisplacement = abs(startVelocity.y * t) - (0.5 * deceleration * pow(t, 2.0))
    let signedDisplacement = sign * unsignedDisplacement
    
    // 가속도가 일정 값 미만일 때 애니메이션 중지
    if unsignedNextVelocity < minAccelerationThreshold {
      stop()
    }
    
    handler?(signedDisplacement, self)
    
    if (unsignedDisplacement <= 0.0 || unsignedNextVelocity <= 0.0) && link != nil {
      stop()
    }
  }
}
