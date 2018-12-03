//
//  CollectionDataProvider.swift
//  CollectionKit
//
//  Created by Casper Zandbergen on 2018-11-30
//

import Foundation
import UIKit

open class PrefetchSource<Data> {
  open var prefetchedIndexes: [Int] = []
  
  open func prefetch(context: PrefetchContext) {
    let frames = prefetchFrames(outsideOf: context.visibleFrame, after: context.offsetChange)
    for frame in frames {
      let indexes = context.visibleIndexes(visibleFrame: frame)
      let notPrefetched = indexes.filter(prefetchedIndexes.contains)
      let data = notPrefetched.map(context.data(at:)) as! [Data]
      prefetch(indexes: notPrefetched, data: data)
      prefetchedIndexes += notPrefetched
    }
  }
  
  open func prefetch(indexes: [Int], data: [Data]) {
    fatalError()
  }
  open func prefetchFrames(outsideOf frame: CGRect, after offsetChange: CGPoint) -> [CGRect] {
    fatalError()
  }
  
  public init() {}
}

open class ClosurePrefetchSource<Data>: PrefetchSource<Data> {
  
  private var prefetch: ([Data]) -> Void
  private var distance: CGFloat
  
  open override func prefetch(indexes: [Int], data: [Data]) {
    prefetch(data)
  }
  
  open override func prefetchFrames(outsideOf frame: CGRect, after offsetChange: CGPoint) -> [CGRect] {
    // prefetch in any direction (not diagonal) for distance
    var frames = [CGRect]()
    if offsetChange.x > 0 {
      frames.append(CGRect(x: frame.maxX, y: frame.minY, width: distance, height: frame.height))
    } else if offsetChange.x < 0 {
      frames.append(CGRect(x: frame.minX - distance, y: frame.minY, width: distance, height: frame.height))
    }
    if offsetChange.y > 0 {
      frames.append(CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: distance))
    } else if offsetChange.y < 0 {
      frames.append(CGRect(x: frame.minX, y: frame.minY - distance, width: frame.width, height: distance))
    }
    return frames
  }
  
  public init(distance: CGFloat, prefetch: @escaping ([Data]) -> Void) {
    self.prefetch = prefetch
    self.distance = distance
  }
}

public class NoPrefetchSource<Data>: PrefetchSource<Data> {
  open override func prefetch(indexes: [Int], data: [Data]) {}
  open override func prefetchFrames(outsideOf frame: CGRect, after offsetChange: CGPoint) -> [CGRect] {
    return []
  }
}

public protocol PrefetchContext {
  var visibleFrame: CGRect { get }
  var offsetChange: CGPoint { get }
  func visibleIndexes(visibleFrame: CGRect) -> [Int]
  func data(at: Int) -> Any
}
