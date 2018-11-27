//
//  ViewController.swift
//  Metal181123
//
//  Created by 余河川 on 2018/11/23.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    

    let mtkView = MTKView.init(frame: .zero)
    var cpls: MTLComputePipelineState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        readyMetal()
    }
    
    override func viewWillLayoutSubviews() {
        self.mtkView.frame = self.view.bounds
    }
    
    func readyMetal() -> Void {
        
        self.view.addSubview(self.mtkView)
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("不支持的设备，真机才可以")
            return
        }
        guard let cpFunc = device.makeDefaultLibrary()?.makeFunction(name: "") else {
            return
        }
        self.mtkView.device = device
        self.cpls = try? device.makeComputePipelineState(function: cpFunc)
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable, let cpls = self.cpls else {
            return
        }
        guard let commendBuffer = view.device?.makeCommandQueue()?.makeCommandBuffer() else {
            return
        }
        
        guard let bufferEncoder = commendBuffer.makeComputeCommandEncoder() else {
            return
        }
        bufferEncoder.setComputePipelineState(cpls)
        bufferEncoder.setTexture(drawable.texture, index: 0)
        let threadsSize = MTLSize.init(width: Int(UIScreen.main.scale), height: Int(UIScreen.main.scale), depth: 1)
        let groupsSzie = MTLSize.init(width: drawable.texture.width / threadsSize.width, height: drawable.texture.height / threadsSize.height, depth: 1)
        bufferEncoder.dispatchThreadgroups(groupsSzie, threadsPerThreadgroup: threadsSize)
        bufferEncoder.endEncoding()
        commendBuffer.present(drawable)
        commendBuffer.commit()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }

}

