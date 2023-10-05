//
//  SectionLayoutConfig.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/05.
//

import UIKit

struct SectionLayoutConfig {
  let itemWidthDimension: NSCollectionLayoutDimension
  let itemHeightDimension: NSCollectionLayoutDimension
  
  let groupWidthDimension: NSCollectionLayoutDimension
  let groupHeightDimension: NSCollectionLayoutDimension
  
  let layoutDirection: LayoutDirection
  let interGroupSpacing: CGFloat
  let contentInsets: NSDirectionalEdgeInsets
  
  enum LayoutDirection {
    case horizontal
    case vertical
  }
}
