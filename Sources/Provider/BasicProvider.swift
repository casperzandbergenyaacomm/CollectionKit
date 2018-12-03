//
//  BasicProvider.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-18.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class BasicProvider<Data, View: UIView>: ItemProvider, LayoutableProvider, CollectionReloadable, PrefetchableProvider {
  
  open var prefetchSource: PrefetchSource<Data>
  open var identifier: String?
  open var dataSource: DataSource<Data> { didSet { setNeedsReload() } }
  open var viewSource: ViewSource<Data, View> { didSet { setNeedsReload() } }
  open var sizeSource: SizeSource<Data> { didSet { setNeedsInvalidateLayout() } }
  open var layout: Layout { didSet { setNeedsInvalidateLayout() } }
  open var animator: Animator? { didSet { setNeedsReload() } }
  open var tapHandler: TapHandler?

  public typealias TapHandler = (TapContext) -> Void

  public struct TapContext {
    public let view: View
    public let index: Int
    public let dataSource: DataSource<Data>

    public var data: Data {
      return dataSource.data(at: index)
    }

    public func setNeedsReload() {
      dataSource.setNeedsReload()
    }
  }

  public init(identifier: String? = nil,
              dataSource: DataSource<Data>,
              prefetchSource: PrefetchSource<Data> = NoPrefetchSource(),
              viewSource: ViewSource<Data, View>,
              sizeSource: SizeSource<Data> = SizeSource<Data>(),
              layout: Layout = FlowLayout(),
              animator: Animator? = nil,
              tapHandler: TapHandler? = nil) {
    self.dataSource = dataSource
    self.prefetchSource = prefetchSource
    self.viewSource = viewSource
    self.layout = layout
    self.sizeSource = sizeSource
    self.animator = animator
    self.tapHandler = tapHandler
    self.identifier = identifier
  }
  
  private var lastPrefetchedFrame: CGRect?
  open func prefetchContext(visibleFrame: CGRect) -> PrefetchContext {
    let context = BasicProviderPrefetchContext(visibleFrame: visibleFrame,
                                               lastVisibleFrame: lastPrefetchedFrame,
                                               dataSource: dataSource,
                                               layout: layout)
    lastPrefetchedFrame = visibleFrame
    return context
  }

  open var numberOfItems: Int {
    return dataSource.numberOfItems
  }
  open func view(at: Int) -> UIView {
    return viewSource.view(data: dataSource.data(at: at), index: at)
  }
  open func update(view: UIView, at: Int) {
    viewSource.update(view: view as! View, data: dataSource.data(at: at), index: at)
  }
  open func identifier(at: Int) -> String {
    return dataSource.identifier(at: at)
  }
  open func layoutContext(collectionSize: CGSize) -> LayoutContext {
    return BasicProviderLayoutContext(collectionSize: collectionSize,
                                      dataSource: dataSource,
                                      sizeSource: sizeSource)
  }
  open func animator(at: Int) -> Animator? {
    return animator
  }
  open func didTap(view: UIView, at: Int) {
    if let tapHandler = tapHandler {
      let context = TapContext(view: view as! View, index: at, dataSource: dataSource)
      tapHandler(context)
    }
  }
  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || reloadable === dataSource || reloadable === sizeSource
  }
}

struct BasicProviderLayoutContext<Data>: LayoutContext {
  var collectionSize: CGSize
  var dataSource: DataSource<Data>
  var sizeSource: SizeSource<Data>

  var numberOfItems: Int {
    return dataSource.numberOfItems
  }
  func data(at: Int) -> Any {
    return dataSource.data(at: at)
  }
  func identifier(at: Int) -> String {
    return dataSource.identifier(at: at)
  }
  func size(at index: Int, collectionSize: CGSize) -> CGSize {
    return sizeSource.size(at: index, data: dataSource.data(at: index), collectionSize: collectionSize)
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
  
  func visibleIndexes(in frame: CGRect) -> [Int] {
    return layout.visible(in: visibleFrame).indexes
  }
  
  func data(at: Int) -> Any {
    return dataSource.data(at: at)
  }
}
