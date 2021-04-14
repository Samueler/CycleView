//
//  CycleView.swift
//  CycleView
//
//  Created by ty.Chen on 2021/4/13.
//

import UIKit
import Kingfisher

public class CycleView: UIView {
    
    // MARK: - Public Properties
    
    /// 本地图片数组
    public var localImages: [UIImage]? {
        didSet {
            guard let count = localImages?.count else { return }
            realCount = count
        }
    }
    
    /// 网络图片链接数组
    public var remoteImages: [String]? {
        didSet {
            guard let count = remoteImages?.count else { return }
            realCount = count
        }
    }
    
    /// 仅当`remoteImages`和`localImages`均赋值时，设置`remoteImages`优先级是否高于`localImages`;默认为`true`
    public var remoteFirst: Bool = true
    
    /// 每个Item的大小
    public var itemSize: CGSize = CGSize(width: 44, height: 44) {
        didSet {
            flowLayout.itemSize = itemSize
        }
    }
    
    /// 各个Item之间的间隔
    public var itemSpacing: CGFloat = 8 {
        didSet {
            flowLayout.minimumLineSpacing = itemSpacing
        }
    }
    
    /// 内容内间距
    public var contentInset: UIEdgeInsets = .zero
    
    /// 是否无限轮播
    public var infiniteLoop: Bool = true {
        didSet {
            if !infiniteLoop {
                totalItemCount = realCount
            }
        }
    }
    
    /// 是否自动滚动
    public var autoScroll: Bool = true {
        didSet {
            if autoScroll {
                startTimer()
            } else {
                cancelTimer()
            }
        }
    }
    
    /// 自动滚动时间间隔
    public var loopTimeInterval: TimeInterval = 2
    
    /// 点击Item的回调
    public var clickItemCallback: ((_ index: Int) -> Void)?
    
    /// 滚动下标的回调
    public var indexUpdateCallback: ((_ index: Int) -> Void)?
    
    /// 自定义Item时的dataSource
    public weak var dataSource: CycleViewDataSource? {
        didSet {
            if let count = dataSource?.numberOfItems?(in: self) {
                realCount = count
            }
        }
    }
    
    /// CycleView的一些回调
    public weak var delegate: CycleViewDelegate?
    
    /// 设置圆角
    public var itemCornerRadius: CGFloat = 0
    
    /// 设置圆角位置
    public var itemRoundingCorners: UIRectCorner = .allCorners
    
    /// 设置图片显示mode
    public var itemContentMode: UIView.ContentMode = .scaleToFill
    
    /// 占位图
    public var itemPlaceholder: UIImage?
    
    // MARK: - Public Properties: ReadOnly
    
    /// 当前滚动到的下标位置
    private(set) var currentIndex: Int = 0 {
        didSet {
            indexUpdateCallback?(currentIndex)
        }
    }
    
    // MARK: - Public Functions
    
    /// 刷新数据
    public func reloadData() {
        
        collectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scrollToInitialPosition()
            self.autoScroll = self.autoScroll ? true : false
        }
    }
    
    /// 滚动至指定下标
    /// - Parameters:
    ///   - index: 目标下标
    ///   - resetTimer: 是否需要重置定时器
    public func scroll(to index: Int, resetTimer: Bool = true) {
        if resetTimer {
            cancelTimer()
        }
        let tempIndex = indexOfIndexPath(IndexPath(item: innerIndex, section: 0))
        let deltaIndex = index - tempIndex
        let targetIndex = innerIndex + deltaIndex
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if targetIndex >= self.totalItemCount || targetIndex < 0 {
                self.scrollToInitialPosition(animated: true)
            } else {
                self.collectionView.setContentOffset(CGPoint(x: self.targetContentOffsetX(for: targetIndex), y: 0), animated: true)
            }
        }
        if resetTimer {
            startTimer()
        }
    }
    
    /// 自定义Item时，注册Item
    /// - Parameter itemType: 自定义Item类型
    public func registerItem<T: UICollectionViewCell>(itemType: T.Type) {
        collectionView.register(itemType, forCellWithReuseIdentifier: String(describing: itemType))
    }
    
    /// 通过Item类型和下标获取Item对象
    /// - Parameters:
    ///   - itemType: Item类型
    ///   - index: Item下标
    /// - Returns: Item对象
    public func dequeueReusableItem<T: UICollectionViewCell>(itemType: T.Type, at index: Int) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: itemType), for: IndexPath(item: index, section: 0)) as? T else {
            fatalError("CycleView dequeue reusable item Error: \(itemType)")
        }
        return cell
    }
    
    /// 通过Item获取Item所对应的下标
    /// - Parameter item: 目标Item
    /// - Returns: Item对应的下标
    public func itemIndex(for item: UICollectionViewCell) -> Int {
        guard let indexPath = collectionView.indexPath(for: item), realCount > 0 else {
            return 0
        }
        
        return indexPath.item % realCount
    }
    
    // MARK: - Private Properties
    
    private var realCount: Int = 0 {
        didSet {
            
            if realCount <= 1 {
                infiniteLoop = false
            }
            
            if infiniteLoop {
                totalItemCount = realCount <= 1 ? realCount : realCount * 100
            } else {
                totalItemCount = realCount
            }
        }
    }
 
    private var totalItemCount: Int = 0
    
    private static var identifier = "CycleVieItemIdentifier"
    
    /// 当未自定义Item时，是否基于`remoteImages`渲染
    private var remoteValid: Bool {
        
        if let remoteCount = remoteImages?.count,
           remoteCount > 0,
           let localCount = localImages?.count,
           localCount > 0 {
            return remoteFirst
        }
        
        if let localCount = localImages?.count,
           localCount > 0 {
            return false
        }
        
        return true
    }
    
    private var innerIndex: Int {
        return Int(collectionView.contentOffset.x / (itemSize.width + itemSpacing))
    }
    
    private var timer: Timer?
    
    // MARK: - Life Cycles
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    deinit {
        cancelTimer()
        print("CycleView deinit!")
    }
    
    // MARK: - Override Functions
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }
    
    // MARK: - Private Functions
    
    private func setupUI() {
        addSubview(collectionView)
    }
    
    private func indexOfIndexPath(_ indexPath: IndexPath) -> Int {
        if realCount <= 0 {
            return 0
        }
        
        return indexPath.item % realCount
    }
    
    private func targetContentOffsetX(for index: Int) -> CGFloat {
        return CGFloat(index) * (itemSize.width + itemSpacing)
    }
    
    private func scrollToInitialPosition(animated: Bool = false) {
        if infiniteLoop {
            collectionView.setContentOffset(CGPoint(x: (CGFloat(totalItemCount) * 0.5) * (itemSize.width + itemSpacing), y: 0), animated: animated)
        } else {
            collectionView.setContentOffset(.zero, animated: true)
        }
    }
    
    private func startTimer() {
        cancelTimer()
        
        if !autoScroll || loopTimeInterval <= 0 || totalItemCount <= 1 {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: loopTimeInterval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.scroll(to: self.currentIndex + 1, resetTimer: false)
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    public func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Lazy Load
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = itemSize
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = itemSpacing
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(CycleViewCell.self, forCellWithReuseIdentifier: CycleView.identifier)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
}

// MARK: - UICollectionViewDataSource

extension CycleView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = dataSource?.numberOfItems?(in: self) {
            realCount = count
        }
        return totalItemCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = dataSource?.cycleView?(self, cellForItemAt: indexOfIndexPath(indexPath)) {
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CycleView.identifier, for: indexPath) as! CycleViewCell
        
        if remoteValid {
            
            if let url = remoteImages?[indexOfIndexPath(indexPath)] {
                cell.imageView.kf.setImage(with: URL(string: url), placeholder: itemPlaceholder)
            } else {
                cell.imageView.image = itemPlaceholder
            }
            
        } else {
            if let image = localImages?[indexOfIndexPath(indexPath)] {
                cell.imageView.image = image
            } else {
                cell.imageView.image = itemPlaceholder
            }
        }
        
        cell.layoutIfNeeded()
        
        if itemCornerRadius > 0 {
            let maskPath = UIBezierPath(roundedRect: cell.imageView.bounds, byRoundingCorners: itemRoundingCorners, cornerRadii: CGSize(width: itemCornerRadius, height: itemCornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = cell.imageView.bounds
            maskLayer.path = maskPath.cgPath
            cell.imageView.layer.mask = maskLayer
        } else {
            cell.imageView.layer.mask = nil
        }
        
        return cell
    }
}

extension CycleView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexOfIndexPath(indexPath)
        
        delegate?.didSelectedItem?(cycleView: self, at: selectedIndex)
        clickItemCallback?(selectedIndex)
    }
}

extension CycleView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tempCurrentIndex = indexOfIndexPath(IndexPath(item: innerIndex, section: 0))
        if currentIndex != tempCurrentIndex {
            currentIndex = tempCurrentIndex
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        CycleView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(pageScroll), object: nil)
        cancelTimer()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        perform(#selector(pageScroll), with: nil, afterDelay: 0)
        startTimer()
    }
     
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        perform(#selector(pageScroll), with: nil, afterDelay: 0)
        startTimer()
    }
    
    @objc private func pageScroll() {
        let targetX = (CGFloat(innerIndex) + 0.5) * (itemSize.width + itemSpacing)
        if collectionView.contentOffset.x <= targetX {
            collectionView.setContentOffset(CGPoint(x: targetContentOffsetX(for: innerIndex), y: 0), animated: true)
        } else {
            collectionView.setContentOffset(CGPoint(x: targetContentOffsetX(for: innerIndex + 1), y: 0), animated: true)
        }
    }
}
