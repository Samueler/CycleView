//
//  CycleViewDataSource.swift
//  CycleView
//
//  Created by ty.Chen on 2021/4/13.
//

import UIKit

@objc public protocol CycleViewDataSource {
    
    /// <#Description#>
    /// - Parameter cycleView: <#cycleView description#>
    @objc optional func numberOfItems(in cycleView: CycleView) -> Int
    
    /// <#Description#>
    /// - Parameters:
    ///   - cycleView: <#cycleView description#>
    ///   - index: <#index description#>
    @objc optional func cycleView(_ cycleView: CycleView, cellForItemAt index: Int) -> UICollectionViewCell
    
}
