//
//  PrefetchableProvider.swift
//  CollectionKit
//
//  Created by Casper Zandbergen on 2018-11-30
//

import UIKit

public protocol PrefetchableProvider {
  associatedtype Data
  var prefetchSource: PrefetchSource<Data> { get }
  func prefetchContext(visibleFrame: CGRect) -> PrefetchContext
}

extension PrefetchableProvider where Self: Provider {
  public func prefetch(visibleFrame: CGRect) {
    prefetchSource.prefetch(context: prefetchContext(visibleFrame: visibleFrame))
  }
}

open class PrefetchableProviderExample<Data,View: UIView>: BasicProvider<Data,View>, PrefetchableProvider {
  
  open var prefetchSource: PrefetchSource<Data>
  private var lastPrefetchedFrame: CGRect?
  
  public init(identifier: String? = nil,
              dataSource: DataSource<Data>,
              prefetchSource: PrefetchSource<Data> = NoPrefetchSource(),
              viewSource: ViewSource<Data, View>,
              sizeSource: SizeSource<Data> = SizeSource<Data>(),
              layout: Layout = FlowLayout(),
              animator: Animator? = nil,
              tapHandler: TapHandler? = nil) {
    self.prefetchSource = prefetchSource
    super.init(identifier: identifier, dataSource: dataSource, viewSource: viewSource, sizeSource: sizeSource, layout: layout, animator: animator, tapHandler: tapHandler)
  }
  
  open func prefetchContext(visibleFrame: CGRect) -> PrefetchContext {
    let context = BasicProviderPrefetchContext(visibleFrame: visibleFrame,
                                               lastVisibleFrame: lastPrefetchedFrame,
                                               dataSource: dataSource,
                                               layout: layout)
    lastPrefetchedFrame = visibleFrame
    return context
  }
}


struct BasicProviderPrefetchContext<Data>: PrefetchContext {
  var visibleFrame: CGRect
  var lastVisibleFrame: CGRect?
  var dataSource: DataSource<Data>
  var layout: Layout
  
  var offsetChange: CGPoint {
    guard let last = lastVisibleFrame else {
      return .zero
    }
    
    var offset = CGPoint.zero
    if visibleFrame.width == last.width {
      offset.x = visibleFrame.minX - last.minX
    } else if visibleFrame.minX == last.minX {
      offset.x = visibleFrame.width - last.width
    }
    if visibleFrame.height == last.height {
      offset.y = visibleFrame.minY - last.minY
    } else if visibleFrame.minY == last.minY {
      offset.y = visibleFrame.height - last.height
    }
    return offset
  }
  
  func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return layout.visibleIndexes(visibleFrame: visibleFrame)
  }
  
  func data(at: Int) -> Any {
    return dataSource.data(at: at)
  }
}
