//
//  CycleViewDataSource.swift
//  CycleView
//
//  Created by ty.Chen on 2021/4/13.
//

import UIKit

@objc public protocol CycleViewDataSource {
    
    /// Item个数
    /// - Parameter cycleView: CycleView
    @objc optional func numberOfItems(in cycleView: CycleView) -> Int
    
    /// 对应下标Item的样式
    /// - Parameters:
    ///   - cycleView: CycleView
    ///   - index: 下标
    @objc optional func cycleView(_ cycleView: CycleView, cellForItemAt index: Int) -> UICollectionViewCell
    
}
