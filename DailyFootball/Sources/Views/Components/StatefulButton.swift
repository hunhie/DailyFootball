//
//  StatefulButton.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/16.
//

import UIKit

class StatefulButton<T: Hashable>: UIButton {
  
  private var stateConfigurations: [T: UIButton.Configuration] = [:]
  private var stateBackgroundColors: [T: UIColor] = [:]
  
  var currentState: T? {
    didSet {
      updateConfigurationForCurrentState()
      updateBackgroundColorForCurrentState()
    }
  }
  
  var config: UIButton.Configuration
  
  init(config: UIButton.Configuration, frame: CGRect = .zero) {
    self.config = config
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setAttributedTitleWithColor(_ title: AttributedString, _ color: UIColor, forState state: T) {
    var config = getOrCreateConfiguration(for: state)
    config.attributedTitle = title
    config.baseForegroundColor = color
    stateConfigurations[state] = config
  }
  
  func setBackgroundColor(_ color: UIColor, forState state: T) {
    stateBackgroundColors[state] = color
  }
  
  private func updateConfigurationForCurrentState() {
    if let state = currentState, let configuration = stateConfigurations[state] {
      self.configuration = configuration
    }
  }
  
  private func updateBackgroundColorForCurrentState() {
    if let state = currentState, let backgroundColor = stateBackgroundColors[state] {
      self.backgroundColor = backgroundColor
    }
  }
  
  private func getOrCreateConfiguration(for state: T) -> UIButton.Configuration {
    if let config = stateConfigurations[state] {
      return config
    } else {
      let newConfig = self.config
      stateConfigurations[state] = newConfig
      return newConfig
    }
  }
}



