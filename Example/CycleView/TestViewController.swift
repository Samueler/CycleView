//
//  TestViewController.swift
//  CycleView_Example
//
//  Created by ty.Chen on 2021/4/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import CycleView

class TestViewController: UIViewController {
    
    var cycleView = CycleView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "TestViewController"
        view.backgroundColor = .white
        
        let remotes = [
            "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F2c.zol-img.com.cn%2Fproduct%2F124_500x2000%2F748%2FceZOdKgDAFsq2.jpg&refer=http%3A%2F%2F2c.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1620916598&t=e1e4753acfaccc79b82e284c1a3a37fd",
            "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fyouimg1.c-ctrip.com%2Ftarget%2Ftg%2F035%2F063%2F726%2F3ea4031f045945e1843ae5156749d64c.jpg&refer=http%3A%2F%2Fyouimg1.c-ctrip.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1620916598&t=752fe0f1308aea5d268554da5a1e2728",
            "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F2c.zol-img.com.cn%2Fproduct%2F124_500x2000%2F984%2FceU7xYD3umwA.jpg&refer=http%3A%2F%2F2c.zol-img.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1620916598&t=382357bcecd30c8d49cbe035e88a2cad",
            "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201412%2F03%2F20141203230557_VERYC.thumb.700_0.jpeg&refer=http%3A%2F%2Fcdn.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1620916598&t=2ef209879883f91a5fdd81821aa449e5",
            "https://gimg2.baidu.com/image_search/src=http%3A%2F%2F1812.img.pp.sohu.com.cn%2Fimages%2Fblog%2F2009%2F11%2F18%2F18%2F8%2F125b6560a6ag214.jpg&refer=http%3A%2F%2F1812.img.pp.sohu.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1620916598&t=4d45bb0dd8fe9b8c700bd88249e8e1ef"
        ]
        
        view.addSubview(cycleView)
        cycleView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 120)
        cycleView.itemSize = cycleView.bounds.size
        cycleView.remoteImages = remotes
        cycleView.delegate = self
        cycleView.itemCornerRadius = 10
        cycleView.autoScroll = true
        cycleView.itemRoundingCorners = .topLeft
        
//        cycleView.clickItemCallback = {
//            print("clickItemCallback:\($0)")
//        }
        
//        cycleView.indexUpdateCallback = {
//            print("indexUpdateCallback: \($0)")
//        }
        
        cycleView.reloadData()
    }
    
    deinit {
        print("TestViewController deinit!")
    }

}

extension TestViewController: CycleViewDelegate {
    func didSelectedItem(cycleView: CycleView, at index: Int) {
        print("didSelectedItem:\(index)")
    }
}
