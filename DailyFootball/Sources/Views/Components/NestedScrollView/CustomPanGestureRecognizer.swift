//
//  CustomPanGestureRecognizer.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/22.
//

import UIKit

/// UIPanGestureRecognizer의 커스텀 서브클래스로, 터치가 시작될 때 추가적인 클로저 핸들러를 제공합니다.
final class CustomPanGestureRecognizer: UIPanGestureRecognizer {
  
  /// 터치 이벤트가 시작될 때 호출될 클로저입니다.
  /// 제스처의 시작 부분에서 사용자 정의 로직을 처리하는 데 유용합니다.
  var touchesBeganHandler: (() -> ())?
  
  /// `touchesBegan` 메소드를 오버라이드하여 사용자 정의 핸들러를 호출합니다.
  ///
  /// - Parameters:
  ///   - touches: 이벤트의 시작 단계에 대한 터치를 나타내는 `UITouch` 객체 세트입니다.
  ///   - event: 터치가 속한 이벤트를 나타내는 객체입니다.
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    
    touchesBeganHandler?()
  }
}
