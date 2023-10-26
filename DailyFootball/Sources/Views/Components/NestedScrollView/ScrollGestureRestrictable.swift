//
//  ScrollGestureRestrictable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/22.
//

import UIKit

/// 스크롤 제스처의 동작을 제한할 수 있는 기능을 제공하는 프로토콜입니다.
protocol ScrollGestureRestrictable where Self: UIScrollView {
  /// 스크롤 제스처의 동작 여부를 결정하는 메소드입니다.
  ///
  /// - Parameters:
  ///   - gestureRecognizer: 판단해야 할 제스처 인식기입니다.
  ///   - defaultResult: 기본 제스처 동작 여부입니다.
  /// - Returns: 제스처의 동작을 허용할지에 대한 Bool 값입니다.
  func shouldRestrictScrollGesture(_ gestureRecognizer: UIGestureRecognizer, defaultResult: Bool) -> Bool
}

/// UIScrollView에 대한 ScrollGestureRestrictable의 기본 구현입니다.
extension UIScrollView: ScrollGestureRestrictable {
  func shouldRestrictScrollGesture(_ gestureRecognizer: UIGestureRecognizer, defaultResult: Bool) -> Bool {
    // pan 제스처일 경우에는 동작을 허용하지 않습니다.
    if gestureRecognizer === panGestureRecognizer {
      return false
    }
    
    return defaultResult
  }
}

/// 스크롤 기능이 비활성화된 UIScrollView의 서브클래스입니다.
class ScrollDisabledScrollView: UIScrollView {
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let result = super.gestureRecognizerShouldBegin(gestureRecognizer)
    return shouldRestrictScrollGesture(gestureRecognizer, defaultResult: result)
  }
}

/// 스크롤 기능이 비활성화된 UITableView의 서브클래스입니다.
class InnerScrollTableView: UITableView {
  
  override init(frame: CGRect, style: UITableView.Style) {
    super.init(frame: frame, style: style)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let result = super.gestureRecognizerShouldBegin(gestureRecognizer)
    return shouldRestrictScrollGesture(gestureRecognizer, defaultResult: result)
  }
}

/// 스크롤 기능이 비활성화된 UICollectionView의 서브클래스입니다.
class InnerScrollCollectionView: UICollectionView {
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let result = super.gestureRecognizerShouldBegin(gestureRecognizer)
    return shouldRestrictScrollGesture(gestureRecognizer, defaultResult: result)
  }
}
