//
//  SVGImageProcessor.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/08.
//

import Kingfisher
import SVGKit

struct SVGImageProcessor: ImageProcessor {
  public let identifier: String = "com.DailyFootball.svgimageprocessor"
  
  func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
    switch item {
    case .image(let image):
      return image
    case .data(let data):
      let svgImage = SVGKImage(data: data)
      return svgImage?.uiImage
    }
  }
}
