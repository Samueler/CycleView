//
//  CycleViewDelegate.swift
//  CycleView
//
//  Created by ty.Chen on 2021/4/13.
//

import UIKit

@objc public protocol CycleViewDelegate {
    
    /// Item被点击时的回调
    /// - Parameters:
    ///   - cycleView: CycleView
    ///   - index: 被点击的下标
    @objc optional func didSelectedItem(cycleView: CycleView, at index: Int)
}
