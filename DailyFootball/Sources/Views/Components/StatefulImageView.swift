//
//  StatefulImageView.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/08.
//

import UIKit

final class StatefulImageView<T: Hashable>: UIImageView {
  private var stateImages: [T: UIImage] = [:]
  
  var currentState: T? {
    didSet {
      updateImageForCurrentState()
    }
  }
  
  func setImage(_ image: UIImage?, forState state: T) {
    stateImages[state] = image
  }
  
  private func updateImageForCurrentState() {
    if let state = currentState, let img = stateImages[state] {
      self.image = img.withRenderingMode(.alwaysTemplate)
    }
  }
}
