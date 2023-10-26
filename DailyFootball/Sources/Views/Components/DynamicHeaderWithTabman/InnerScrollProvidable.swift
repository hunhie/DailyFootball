//
//  InnerScrollProvidable.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/22.
//

import UIKit

protocol InnerScrollProvidable: AnyObject {
  var innerScroll: ScrollGestureRestrictable { get }
  func setupInnerScroll()
}
