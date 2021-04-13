//
//  ViewController.swift
//  CycleView
//
//  Created by Samueler on 04/13/2021.
//  Copyright (c) 2021 Samueler. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func clickAction(_ sender: Any) {
        let vc = TestViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

