//
//  SectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-13.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import Foundation
import UIKit

public protocol SectionProvider: Provider {
  func section(at: Int) -> Provider?
}

extension SectionProvider {
  public func flattenedProvider() -> ItemProvider {
    return FlattenedProvider(provider: self)
  }
  public func prefetch(visibleFrame: CGRect) {
    // prefetching sections is done in the flattened provider
  }
}
