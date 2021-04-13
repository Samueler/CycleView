//
//  CycleViewDelegate.swift
//  CycleView
//
//  Created by ty.Chen on 2021/4/13.
//

import UIKit

@objc public protocol CycleViewDelegate {
    
    /// <#Description#>
    /// - Parameters:
    ///   - cycleView: <#cycleView description#>
    ///   - index: <#index description#>
    @objc optional func didSelectedItem(cycleView: CycleView, at index: Int)
}
