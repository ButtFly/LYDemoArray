//
//  LYReaderView.swift
//  Metal181204
//
//  Created by 余河川 on 2018/12/4.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit


class LYRender : Any {
    
    func ly_sendToRender(drawable: CAMetalDrawable) -> Void {
    }
    
    func ly_prepareRender() -> Bool {
        return true
    }
    
    func ly_didSendToRender() -> Void {
    }
    
    final func ly_render(drawable: CAMetalDrawable) {
        if !ly_prepareRender() {
            return
        }
        ly_sendToRender(drawable: drawable)
        ly_didSendToRender()
    }
    
}

class LYComputeRender: LYRender {
    
    var computePipelineState: MTLComputePipelineState?
    var texture: MTLTexture?
    var time:uint = 0
    
    init(functionName: String) {
        
        super.init()
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        guard let lib = device.makeDefaultLibrary() else {
            return
        }
        guard let computeFunc = lib.makeFunction(name: functionName) else {
            return
        }
        self.computePipelineState = try? device.makeComputePipelineState(function: computeFunc)
        let textureloader = MTKTextureLoader.init(device: device)
        textureloader.newTexture(name: "texture", scaleFactor: UIScreen.main.scale, bundle: nil, options: [:]) { (texture, error) in
            self.texture = texture
        }
        
    }
    
    override func ly_prepareRender() -> Bool {
        return self.texture != nil
    }
    
    override func ly_didSendToRender() {
        self.time += 1
    }
    
    override func ly_sendToRender(drawable: CAMetalDrawable) {
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        
        guard let cpls = self.computePipelineState, let commandBuffer = device.makeCommandQueue()?.makeCommandBuffer(),let timeBuffer = device.makeBuffer(length: MemoryLayout<uint>.size, options: []), let inTexture = self.texture else {
            return
        }
        
        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        commandEncoder.setComputePipelineState(cpls)
        commandEncoder.setTexture(drawable.texture, index: 0)
        commandEncoder.setTexture(inTexture, index: 1)
        memcpy(timeBuffer.contents(), &self.time, MemoryLayout<uint>.size)
        commandEncoder.setBuffer(timeBuffer, offset: 0, index: 0)
        let threadsSize = MTLSize.init(width: Int(UIScreen.main.scale), height: Int(UIScreen.main.scale), depth: 1)
        let groupsSzie = MTLSize.init(width: drawable.texture.width / threadsSize.width, height: drawable.texture.height / threadsSize.height, depth: 1)
        commandEncoder.dispatchThreadgroups(groupsSzie, threadsPerThreadgroup: threadsSize)
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
}






class LYReaderView : UIView, MTKViewDelegate {
    
    public var render: LYRender?
    
    private(set) var mtkView = MTKView.init(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.addSubview(self.mtkView)
        _ly_initMTKView()
    }
    
    func _ly_initMTKView() -> Void {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        self.mtkView.device = device
        self.mtkView.delegate = self
        self.mtkView.framebufferOnly = false
        self.mtkView.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.mtkView.frame = self.bounds
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let render = self.render else {
            return
        }
        
        guard let drawable = view.currentDrawable else {
            return
        }
        render.ly_render(drawable: drawable)
        
    }

}
