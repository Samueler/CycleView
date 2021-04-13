//
//  CycleViewCell.swift
//  CycleView
//
//  Created by ty.Chen on 2021/4/13.
//

import UIKit

final class CycleViewCell: UICollectionViewCell {
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
    
    // MARK: - Private Functions
    
    private func setupUI() {
        contentView.addSubview(imageView)
    }
    
    // MARK: - Lazy Load
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
}
