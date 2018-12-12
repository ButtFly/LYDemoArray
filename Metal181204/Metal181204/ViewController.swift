//
//  ViewController.swift
//  Metal181204
//
//  Created by 余河川 on 2018/12/4.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    let metalView = LYReaderView.init(frame: .zero)
    let render = LYComputeRender.init(functionName: "computeFunction")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(self.metalView)
        self.metalView.frame = self.view.bounds
        self.metalView.render = self.render
    }


}

