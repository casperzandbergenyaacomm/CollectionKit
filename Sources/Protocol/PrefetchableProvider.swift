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
  public func prefetch(outside visibleFrame: CGRect) {
    prefetchSource.prefetch(context: prefetchContext(visibleFrame: visibleFrame))
  }
}

