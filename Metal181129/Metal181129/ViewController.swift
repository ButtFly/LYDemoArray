//
//  ViewController.swift
//  Metal181129
//
//  Created by 余河川 on 2018/11/29.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    
    
    let mtkView = MTKView.init(frame: .zero)
    var cpls: MTLComputePipelineState?
    var hd: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _ly_initMtkView()
        let link = CADisplayLink.init(target: self, selector: #selector(_ly_displayLinkAction))
        link.add(to: .main, forMode: .common)
        
    }
    
    @objc func _ly_displayLinkAction() -> Void {
        
        hd += 1
        
    }
    
    func _ly_initMtkView() -> Void {
        
        self.view.addSubview(self.mtkView)
        self.mtkView.device = MTLCreateSystemDefaultDevice()
        self.mtkView.delegate = self
        self.mtkView.framebufferOnly = false
        guard let device = self.mtkView.device else {
            return
        }
        let lib = device.makeDefaultLibrary()
        guard let computeFunc = lib?.makeFunction(name: "ls_compute") else {
            return
        }
        self.cpls = try? device.makeComputePipelineState(function: computeFunc)
        
    }
    
    override func viewWillLayoutSubviews() {
        self.mtkView.frame = self.view.bounds
    }

    func draw(in view: MTKView) {
        
        guard let cpls = self.cpls, let drawable = view.currentDrawable, let device = view.device else {
            return
        }
        guard let commendBuffer = device.makeCommandQueue()?.makeCommandBuffer() else {
            return
        }
        guard let commendEncoder = commendBuffer.makeComputeCommandEncoder() else {
            return
        }
        commendEncoder.setComputePipelineState(cpls)
        commendEncoder.setTexture(drawable.texture, index: 0)
        let timeBuffer = device.makeBuffer(length: MemoryLayout<UInt>.size, options: [])
        memcpy(timeBuffer?.contents(), &self.hd, MemoryLayout<UInt>.size)
        commendEncoder.setBuffer(timeBuffer, offset: 0, index: 0)
        let tLength: Int = Int(UIScreen.main.scale)
        let threads = MTLSize.init(width: tLength, height: tLength, depth: 1)
        let threadgroups = MTLSize.init(width: drawable.texture.width / tLength, height: drawable.texture.height / tLength, depth: 1)
        commendEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threads)
        commendEncoder.endEncoding()
        commendBuffer.present(drawable)
        commendBuffer.commit()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }

}

