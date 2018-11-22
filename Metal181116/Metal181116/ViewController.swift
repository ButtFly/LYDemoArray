//
//  ViewController.swift
//  Metal181116
//
//  Created by 余河川 on 2018/11/16.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    
    struct Vertex {
        var position: float4
        var color: float4
    }
    
    let mtkView = MTKView.init(frame: CGRect.zero)
    let device = MTLCreateSystemDefaultDevice()
    let vertexData = [Vertex.init(position: [-1.0, 1.0, 1.0, 1.0], color: [1, 1, 1 , 1]),
                      Vertex.init(position: [-1.0, -1.0, 1.0, 1.0], color: [1, 0, 0 , 1]),
                      Vertex.init(position: [1.0, -1.0, 1.0, 1.0], color: [1, 1, 0 , 1]),
                      Vertex.init(position: [1.0, 1.0, 1.0, 1.0], color: [0, 1, 0, 1]),
                      Vertex.init(position: [-1.0, 1.0, -1.0, 1.0], color: [0, 0, 1 , 1]),
                      Vertex.init(position: [-1.0, -1.0, -1.0, 1.0], color: [1, 0, 1 , 1]),
                      Vertex.init(position: [1.0, -1.0, -1.0, 1.0], color: [0, 0, 0 , 1]),
                      Vertex.init(position: [1.0, 1.0, -1.0, 1.0], color: [0, 1, 1 , 1])]
    
    
    let idxData: [uint] = [0, 1, 2, 2, 3, 0,   // front
        1, 5, 6, 6, 2, 1,   // right
        3, 2, 6, 6, 7, 3,   // top
        4, 5, 1, 1, 0, 4,   // bottom
        4, 0, 3, 3, 7, 4,   // left
        7, 6, 5, 5, 4, 7]   // back
    lazy var rpd: MTLRenderPipelineDescriptor = {
        let rpd = MTLRenderPipelineDescriptor.init()
        let library = self.device?.makeDefaultLibrary()
        rpd.vertexFunction = library?.makeFunction(name: "allVertex")
        rpd.fragmentFunction = library?.makeFunction(name: "verTexColor")
        rpd.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat
        return rpd
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(self.mtkView)
        self.mtkView.device = MTLCreateSystemDefaultDevice()
        self.mtkView.delegate = self
        self.mtkView.isOpaque = false
        
    }
    
    override func viewWillLayoutSubviews() {
        self.mtkView.frame = self.view.bounds
    }
    
    func modelMatrix() -> matrix_float4x4 {
        
        let scaled = scalingMatrix(scale: 0.5)
        let rotatedY = rotationMatrix(angle: Float(Double.pi)/4, axis: float3(0, 1, 0))
        let rotatedX = rotationMatrix(angle: Float(Double.pi)/4, axis: float3(1, 0, 0))
        let modelMatrix = matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaled)
        let cameraPosition = vector_float3(0, 0, -3)
        let viewMatrix = translationMatrix(position: cameraPosition)
        let projMatrix = projectionMatrix(near: 0, far: 10, aspect: 1, fovy: 1)
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
        return modelViewProjectionMatrix
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        if let rpd = view.currentRenderPassDescriptor, let drawAble = view.currentDrawable, let device = self.device, let rps = try? device.makeRenderPipelineState(descriptor: self.rpd) {
            
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 0)
            let commandQueue = device.makeCommandQueue()
            let commandBuffer = commandQueue?.makeCommandBuffer()
            let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
            encoder?.setRenderPipelineState(rps)
            encoder?.setVertexBuffer(device.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.size * vertexData.count, options: []), offset: 0, index: 0)
            encoder?.setVertexBuffer(device.makeBuffer(bytes: idxData, length: MemoryLayout<uint>.size * idxData.count, options: []), offset: 0, index: 1)
            var matrix = modelMatrix()
            let matrixBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
            memcpy(matrixBuffer?.contents(), &matrix, MemoryLayout<matrix_float4x4>.size)
            encoder?.setVertexBuffer(matrixBuffer, offset: 0, index: 2)
            encoder?.setFrontFacing(.counterClockwise)
            encoder?.setCullMode(.back)
            encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: idxData.count)
            encoder?.endEncoding()
            commandBuffer?.present(drawAble)
            commandBuffer?.commit()
            
            
        }
        
    }

}

