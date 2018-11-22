//
//  ViewController.swift
//  Metal181116_2
//
//  Created by 余河川 on 2018/11/16.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    

    
    public var device: MTLDevice!
    var queue: MTLCommandQueue!
    var cps: MTLComputePipelineState!
    let mtkView = MTKView.init(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(mtkView)
        self.mtkView.delegate = self
        device = MTLCreateSystemDefaultDevice()!
        self.mtkView.delegate = self
        self.mtkView.device = self.device
        self.mtkView.framebufferOnly = false
        registerShaders()
        
        
    }
    
    override func viewWillLayoutSubviews() {
        self.mtkView.frame = self.view.bounds
    }
    
    func registerShaders() {
        device = MTLCreateSystemDefaultDevice()!
        queue = device.makeCommandQueue()
        let library = device.makeDefaultLibrary()
        let kernel = library?.makeFunction(name: "compute")!
        cps = try! device.makeComputePipelineState(function: kernel!)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        mtkView.isPaused = false
    }
    
    func draw(in view: MTKView) {
        
        if let drawable = view.currentDrawable,
            let commandBuffer = queue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(cps)
            commandEncoder.setTexture(drawable.texture, index: 0)
            let threadGroupCount = MTLSizeMake(8, 8, 1)
            let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            mtkView.isPaused = true
        }
        
    }


}

