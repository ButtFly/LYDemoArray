//
//  ViewController.swift
//  Metal181113
//
//  Created by 余河川 on 2018/11/13.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit


class LYHelloMetalView: MTKView {
    
}


class ViewController: UIViewController, MTKViewDelegate {

    let mkView = LYHelloMetalView.init(frame: CGRect.zero)
    var rps: MTLRenderPipelineState?
    var drawCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(mkView)
        view.backgroundColor = UIColor.gray
        mkView.delegate = self;
        mkView.device = MTLCreateSystemDefaultDevice()
        mkView.colorPixelFormat = .rgba16Float
        mkView.isOpaque = false
        rps = makeRenderPipelineState()
        
    }
    
    override func viewWillLayoutSubviews() {
        var frame = view.bounds
        let safeInset = view.safeAreaInsets
        frame.origin.x += safeInset.left
        frame.origin.y += safeInset.top
        frame.size.width -= (safeInset.left + safeInset.right)
        frame.size.height -= (safeInset.top + safeInset.bottom)
        mkView.frame = frame
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        view.isPaused = false
        
    }
    
    func draw(in view: MTKView) {
        
        if view.device == nil {
            print("不支持的设备")
            return
        }
        
        if let buffer = makeVertexBuffer(), let rpsT = rps, drawCount % 100 == 0 {
            sendToGPU(vertexBuffer: buffer, renderPipelineState: rpsT)
        }
        drawCount += 1
        
//        view.isPaused = true
        
    }
    
    func makeRenderPipelineState() -> MTLRenderPipelineState? {
        
        let library = mkView.device!.makeDefaultLibrary()
        let vertexFunc = library?.makeFunction(name: "vertexFunc")
        let fragmentFunc = library?.makeFunction(name: "fragmentFunc")
        
        let epld = MTLRenderPipelineDescriptor.init()
        epld.vertexFunction = vertexFunc
        epld.fragmentFunction = fragmentFunc
        epld.colorAttachments[0].pixelFormat = mkView.colorPixelFormat
        return try! mkView.device?.makeRenderPipelineState(descriptor: epld)
        
    }
    
    func makeVertexBuffer() -> [MTLBuffer]? {
        
        struct Vertex {
            var position: vector_float4
            var color: vector_float4
        };
        
        let vertexData: [Vertex] = [
            Vertex.init(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
            Vertex.init(position: [1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
            Vertex.init(position: [0.0, 1.0, 0.0, 1.0], color: [0, 0, 1, 1])
        ]
        
        let dataSize = vertexData.count * MemoryLayout<Vertex>.size
        if  let vertextBuffer = mkView.device!.makeBuffer(bytes: vertexData, length: dataSize, options: []) {
            
            var transform3d = CATransform3DIdentity
            transform3d = CATransform3DScale(transform3d, 1, 1, 1)
            transform3d = CATransform3DRotate(transform3d, CGFloat.pi * 0.001 * CGFloat(drawCount), 0, 0, 1)
            
            let transform3dBuffer = mkView.device?.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
            let bufferPointer = transform3dBuffer?.contents()
            let mixT: [Float] = [Float(transform3d.m11), Float(transform3d.m12), Float(transform3d.m13), Float(transform3d.m14),
                                 Float(transform3d.m21), Float(transform3d.m22), Float(transform3d.m23), Float(transform3d.m24),
                                 Float(transform3d.m31), Float(transform3d.m32), Float(transform3d.m33), Float(transform3d.m34),
                                 Float(transform3d.m41), Float(transform3d.m42), Float(transform3d.m43), Float(transform3d.m44)];
            memcpy(bufferPointer, mixT, MemoryLayout<Float>.size * 16)
            var result = [vertextBuffer]
            if transform3dBuffer != nil {
                result.append(transform3dBuffer!)
            }
            return result
            
        } else {
            return nil
        }
        
    }
    
    func sendToGPU(vertexBuffer: [MTLBuffer], renderPipelineState: MTLRenderPipelineState) -> Void {
        
        if let rpd = mkView.currentRenderPassDescriptor, let drawable = mkView.currentDrawable {
            
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 0)
            let commendBuffer = mkView.device?.makeCommandQueue()?.makeCommandBuffer()
            let commendEncoder = commendBuffer?.makeRenderCommandEncoder(descriptor: rpd)
            for (idx, value) in vertexBuffer.enumerated() {
                commendEncoder?.setVertexBuffer(value, offset: 0, index: idx)
            }
            commendEncoder?.setRenderPipelineState(renderPipelineState)
            commendEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            commendEncoder?.endEncoding()
            commendBuffer?.present(drawable)
            commendBuffer?.commit()
            
        }
        
    }

}

