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
    
    public var localImages: [UIImage]? {
        didSet {
            guard let count = localImages?.count else { return }
            realCount = count
        }
    }
    
    public var remoteImages: [String]? {
        didSet {
            guard let count = remoteImages?.count else { return }
            realCount = count
        }
    }
    
    /// 仅当`remoteImages`和`localImages`均赋值时，设置`remoteImages`优先级是否高于`localImages`;默认为`true`
    public var remoteFirst: Bool = true
    
    public var itemSize: CGSize = CGSize(width: 44, height: 44) {
        didSet {
            flowLayout.itemSize = itemSize
        }
    }
    
    public var itemSpacing: CGFloat = 8 {
        didSet {
            flowLayout.minimumLineSpacing = itemSpacing
        }
    }
    
    public var contentInset: UIEdgeInsets = .zero
    
    public var infiniteLoop: Bool = true
    
    public var autoScroll: Bool = true {
        didSet {
            if autoScroll {
                startTimer()
            } else {
                cancelTimer()
            }
        }
    }
    
    public var loopTimeInterval: TimeInterval = 2
    
    public var clickItemCallback: ((_ index: Int) -> Void)?
    
    public var indexUpdateCallback: ((_ index: Int) -> Void)?
    
    public weak var dataSource: CycleViewDataSource? {
        didSet {
            if let count = dataSource?.numberOfItems?(in: self) {
                realCount = count
            }
        }
    }
    
    public weak var delegate: CycleViewDelegate?
    
    public var itemCornerRadius: CGFloat = 0
    
    public var itemRoundingCorners: UIRectCorner = .allCorners
    
    public var itemContentMode: UIView.ContentMode = .scaleToFill
    
    public var itemPlaceholder: UIImage?
    
    // MARK: - Public Properties: ReadOnly
    
    private(set) var currentIndex: Int = 0 {
        didSet {
            indexUpdateCallback?(currentIndex)
        }
    }
    
    // MARK: - Public Functions
    
    public func reloadData() {
        collectionView.reloadData()
    }
        
    public func scroll(to index: Int) {
        let tempIndex = indexOfIndexPath(IndexPath(item: innerIndex, section: 0))
        let deltaIndex = index - tempIndex
        
        print("scrollTo: \(innerIndex + deltaIndex)")
        
        collectionView.setContentOffset(CGPoint(x: targetContentOffsetX(for: innerIndex + deltaIndex), y: 0), animated: true)
    }
    
    public func registerItem<T: UICollectionViewCell>(itemType: T.Type) {
        collectionView.register(itemType, forCellWithReuseIdentifier: String(describing: itemType))
    }
    
    // MARK: - Private Properties
    
    private var realCount: Int = 0 {
        didSet {
            totalItemCount = realCount <= 1 ? realCount : realCount * 100
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
    
    private func startTimer() {
        cancelTimer()
        
        if !autoScroll || loopTimeInterval <= 0 {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: loopTimeInterval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.scroll(to: self.currentIndex + 1)
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
        
//        if itemCornerRadius > 0 {
//            let maskPath = UIBezierPath(roundedRect: cell.imageView.bounds, byRoundingCorners: itemRoundingCorners, cornerRadii: CGSize(width: itemCornerRadius, height: itemCornerRadius))
//            let maskLayer = CAShapeLayer()
//            maskLayer.frame = cell.imageView.bounds
//            maskLayer.path = maskPath.cgPath
//            cell.imageView.layer.mask = maskLayer
//        } else {
//            cell.imageView.layer.mask = nil
//        }
        
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
        cancelTimer()
        
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        pageScroll()
        
        startTimer()
    }
     
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageScroll()
    }
    
    private func pageScroll() {
        let targetX = (CGFloat(innerIndex) + 0.5) * (itemSize.width + itemSpacing)
        if collectionView.contentOffset.x <= targetX {
            collectionView.setContentOffset(CGPoint(x: targetContentOffsetX(for: innerIndex), y: 0), animated: true)
        } else {
            collectionView.setContentOffset(CGPoint(x: targetContentOffsetX(for: innerIndex + 1), y: 0), animated: true)
        }
    }
}
