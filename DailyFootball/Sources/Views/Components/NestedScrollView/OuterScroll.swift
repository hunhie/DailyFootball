//
//  OuterScroll.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/22.
//

import UIKit

/// `OuterScrollDelegate`는 `OuterScroll`의 동작에 필요한 정보나 액션을 위한 프로토콜입니다.
/// 구현체에서는 이 프로토콜을 통해 `OuterScroll`과 상호 작용할 수 있습니다.
protocol OuterScrollDelegate: AnyObject {
  
  /// 스크롤 전환 시점의 높이를 반환하는 메서드.
  /// - Returns: 스크롤이 전환되는 Y 좌표 임계값.
  func ScrollTransitionHeight() -> CGFloat
}

/// `OuterScroll`은 외부 스크롤뷰를 나타내는 클래스입니다.
final class OuterScroll: ScrollDisabledScrollView {
  
  // MARK: - 활성화 중인 스크롤 뷰 관리
  
  enum ActiveScroll {
    case outer
    case inner
  }
  
  // MARK: - 스크롤 오프셋 관리
  
  /// 외부 및 내부 스크롤 뷰의 Y 좌표 오프셋을 저장하는 구조체
  private struct ScrollOffsets {
    var outerScrollViewOffset: CGFloat
    var innerScrollViewOffset: CGFloat
    
    init(_ outer: CGFloat, _ inner: CGFloat) {
      self.outerScrollViewOffset = outer
      self.innerScrollViewOffset = inner
    }
  }
  
  // MARK: - 프로퍼티
  
  /// 내부 스크롤 뷰 참조
  /// 내부 스크롤 뷰는 ScrollGestureRestrictable를 준수하는 객체를 요구합니다.
  weak var innerScrollView: ScrollGestureRestrictable? {
    didSet {
      scrollAnimator.stop()
    }
  }
  
  /// 현재 스크롤 영역이 Outer 영역인지 여부
  var isAboveTransitionThreshold: Bool {
    activeScrollView == .outer ? true : false
  }
  
  /// 현재 스크롤 중인 스크롤 뷰
  private var activeScrollView: ActiveScroll = .outer {
    didSet {
      if oldValue == .inner && activeScrollView == .outer {
        NotificationCenter.default.post(name: Notification.Name("OuterScrollDidBecomeVisible"), object: nil)
      }
    }
  }
  
  /// 내부, 외부 스크롤 뷰의 초기 오프셋
  private var initialScrollViewOffset: ScrollOffsets = .init(.zero, .zero)
  
  /// 스크롤이 전환되는 높이 임계값
  private lazy var scrollTransitionThreshold: CGFloat = scrollDelegate?.ScrollTransitionHeight() ?? 0.0
  
  /// 스크롤 애니메이션을 처리하는 객체
  private var scrollAnimator = ScrollViewScrollAnimator()
  
  /// 사용자 정의 팬(Pan) 제스처 인식기
  private weak var customPanGesture: CustomPanGestureRecognizer?
  
  /// OuterScroll Delegate
  weak var scrollDelegate: OuterScrollDelegate?
  
  // MARK: - 초기화
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    setupGesture()
  }
  
  // MARK: - 커스텀 제스처 설정
  
  /// 커스텀 제스처 설정
  private func setupGesture() {
    let panGesture = CustomPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    self.addGestureRecognizer(panGesture)
    self.customPanGesture = panGesture
    
    setupGestureCustomHandler()
  }
  
  // MARK: - 커스텀 팬 제스처 처리
  
  private func setupGestureCustomHandler() {
    customPanGesture?.touchesBeganHandler = { [weak self] in
      guard let self else { return }
      self.scrollAnimator.stop()
    }
  }
  
  /// 커스텀 팬 제스처의 동작을 처리하는 메서드
  @objc private func handlePanGesture(_ sender: CustomPanGestureRecognizer) {
    let translation = sender.translation(in: self)
    let velocity = sender.velocity(in: self)
    
    switch sender.state {
    case .began:
      scrollAnimator.stop()
      updateInitialOffsets()
      handleContentOffset(translation.y)
      
    case .changed:
      handleContentOffset(translation.y)
      
    case .cancelled, .ended:
      handleContentOffset(translation.y)
      animateScrollVelocity(translation, velocity)
      
    default:
      break
    }
  }
  
  // MARK: - 초기 오프셋 업데이트
  
  /// 초기 오프셋 값을 업데이트
  private func updateInitialOffsets() {
    guard let innerScrollView = innerScrollView else { return }
    
    initialScrollViewOffset.outerScrollViewOffset = contentOffset.y
    initialScrollViewOffset.innerScrollViewOffset = innerScrollView.contentOffset.y
  }
  
  // MARK: - 스크롤 애니메이션(관성 스크롤)
  
  /// 스크롤 속도에 따라 스크롤 애니메이션 처리
  private func animateScrollVelocity(_ translation: CGPoint, _ velocity: CGPoint) {
    guard let innerScrollView = innerScrollView else { return }
    
    let decelerationRate = decelerationRate.rawValue * 1000.0
    let scrollDirectionSign = translation.y / abs(translation.y)
    
    // 초기 오프셋 업데이트
    updateInitialOffsets()
    
    // 스크롤 애니메이션 시작
    scrollAnimator.start(scrollDirectionSign, velocity, decelerationRate) { [weak self] (newTranslation, animator) in
      guard let self = self else { return }
      
      // 애니메이터가 계산한 변화량을 스크롤에 적용
      // 사용자의 제스처 속도, 감속률, 스크롤 방향에 의해 계산됨
      self.handleContentOffset(newTranslation)
      
      // 외부 스크롤이 화면 최상단일 경우
      if self.contentOffset.y <= 0 {
        animator.stop()
      }
      // 내부 스크롤이 최하단일 경우
      else if innerScrollView.contentOffset.y >= innerScrollView.contentSize.height - innerScrollView.frame.height {
        animator.stop()
      }
    }
  }
  
  // MARK: - Content Offset 계산
  
  /// 주어진 팬 제스처 변화량에 따라 외부 및 내부 스크롤뷰의 contentOffset 변경
  private func handleContentOffset(_ translation: CGFloat) {
    guard let innerScrollView = innerScrollView else { return }
    
    let calculation = calculateContentOffsets(translation)
    
    contentOffset.y = calculation.outerScrollViewOffset
    innerScrollView.contentOffset.y = calculation.innerScrollViewOffset
  }
  
  /// contentOffset 변경 계산
  private func calculateContentOffsets(_ translation: CGFloat) -> ScrollOffsets {
    guard let innerScroll = innerScrollView else { fatalError("InnerScroll Reference is nil") }
    
    // 스크롤 값
    // 팬 제스처의 변화량
    // 스크롤 방향과 통일하기 위해 부호 반전
    let t = -translation
    
    /// 스크롤 전환 임계 값
    let h = scrollTransitionThreshold
    
    /// 스크롤 초기 __Outer Offset__
    let iO = initialScrollViewOffset.outerScrollViewOffset
    /// 스크롤 초기 __Inner Offset__
    let iN = initialScrollViewOffset.innerScrollViewOffset
    
    /// 스크롤 위치 계산
    let calculatedOffset = iO + iN + t
    
    // 스크롤 Offset 객체
    var r = ScrollOffsets(contentOffset.y, innerScroll.contentOffset.y)
    
    /// 스크롤 적용
    switch activeScrollView {
    case .outer:
      let safeOuterOffset = max(0, calculatedOffset)
      let maxOffset = h
      let clampedOffset = min(safeOuterOffset, maxOffset)
      r.outerScrollViewOffset = clampedOffset
    case .inner:
      let safeInnerOffset = max(0, calculatedOffset - h)
      let maxOffset = innerScroll.contentSize.height - innerScroll.frame.height
      let clampedOffset = min(safeInnerOffset, maxOffset)
      r.innerScrollViewOffset = clampedOffset
    }
    
    /// 활성화된 스크롤 전환
    activeScrollView = calculatedOffset >= h ? .inner : .outer

    return r
  }
}
