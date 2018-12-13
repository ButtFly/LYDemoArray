//
//  ViewController.swift
//  BrushDemo2
//
//  Created by 余河川 on 2018/11/28.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {

    let mtkView = MTKView.init(frame: .zero)
    var buffer = [Int32].init()
    var pointPath = [float2]()
    var cpls: MTLComputePipelineState?
    var renderBufferCount = 0
    var needRenderBufferCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.black
        _ly_initMtkView()
        _ly_initBuffer()
    }
    
    func _ly_initMtkView() -> Void {
        
        self.view.addSubview(self.mtkView)
        self.mtkView.frame = self.view.bounds
        self.mtkView.device = MTLCreateSystemDefaultDevice()
        self.mtkView.delegate = self
        self.mtkView.framebufferOnly = false
        guard let device = self.mtkView.device else {
            return
        }
        let lib = device.makeDefaultLibrary()
        guard let computeFunc = lib?.makeFunction(name: "computerFunction") else {
            return
        }
        self.cpls = try? device.makeComputePipelineState(function: computeFunc)
        
    }
    
    func _ly_initBuffer() -> Void {
        guard let drawable = self.mtkView.currentDrawable else {
            return
        }
        self.buffer = [Int32].init(repeating: 0, count: drawable.texture.width * drawable.texture.height)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: self.mtkView) else {
            return
        }
        _ly_pointPathAddPoint(point: float2(Float(point.x), Float(point.y)))
        
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: self.mtkView) else {
            return
        }
        _ly_pointPathAddPoint(point: float2(Float(point.x), Float(point.y)))
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.pointPath.removeAll()
    }
    
    func draw(in view: MTKView) {
        
        if self.renderBufferCount == self.needRenderBufferCount {
            return
        }
        
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
        let screenBuffer = device.makeBuffer(length: MemoryLayout<Int32>.size * self.buffer.count, options: [])
        memcpy(screenBuffer?.contents(), &self.buffer, MemoryLayout<Int32>.size * self.buffer.count)
        commendEncoder.setBuffer(screenBuffer, offset: 0, index: 0)
        let screenSizeBuffer = device.makeBuffer(length: MemoryLayout<int2>.size, options: [])
        var bufferCount = self.buffer.count
        memcpy(screenSizeBuffer?.contents(), &bufferCount, MemoryLayout<Int>.size)
        commendEncoder.setBuffer(screenSizeBuffer, offset: 0, index: 1)
        
        let tLength: Int = 8
        let threads = MTLSize.init(width: tLength, height: tLength, depth: 1)
        let threadgroups = MTLSize.init(width: drawable.texture.width / tLength, height: drawable.texture.height / tLength, depth: 1)
        commendEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threads)
        commendEncoder.endEncoding()
        commendBuffer.present(drawable)
        commendBuffer.commit()
        self.renderBufferCount += 1
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func _ly_pointPathAddPoint(point: float2) -> Void {
        
        self.pointPath.append(point)
        if self.pointPath.count == 1 {
            _ly_renderTextureBufferWithTouchPoint(point: point)
            self.needRenderBufferCount += 1
            return
        }
        for pointT in _ly_linePathPoint(startPoint: self.pointPath[self.pointPath.count - 2], endPoint: point) {
            _ly_renderTextureBufferWithTouchPoint(point: pointT)
        }
        self.needRenderBufferCount += 1
        
    }
    
    func _ly_renderTextureBufferWithTouchPoint(point: float2) -> Void {
        guard let drawable = self.mtkView.currentDrawable else {
            return
        }
        let sw = Float(self.mtkView.frame.size.width)
        let sh = Float(self.mtkView.frame.size.height)
        let tw = Float(drawable.texture.width)
        let th = Float(drawable.texture.height)
        let rX = Int(point.x / sw * tw)
        let rY = Int(point.y / sh * th)
        let upper = 8 * tw / sw
        
        for i in -Int(upper)...Int(upper) {
            for j in -Int(upper)...Int(upper) {
                
                let nY = rY + i
                let nX = rX + j
                if (length(float2(Float(i), Float(j))) < upper - 10 && nY >= 0 && nX >= 0 && nY < Int(th) && nX < Int(tw)) {
                    self.buffer[(rY + i) * drawable.texture.width + (rX + j)] = 255
                } else if (length(float2(Float(i), Float(j))) <= upper && nY >= 0 && nX >= 0 && nY < Int(th) && nX < Int(tw)) {
                    let x = (upper - length(float2(Float(i), Float(j)))) * 0.1
                    let smoothValue = x * x * x * (x * (x * 6 - 15) + 10)
                    self.buffer[(rY + i) * drawable.texture.width + (rX + j)] += Int32(smoothValue * 255)
                }
                
            }
        }
        
    }
    
    
    func _ly_besselPathPoints(point1: float2, point2: float2, controlPoint: float2) -> [float2] {
        
        let lengh = length(point2 - point1)
        var points = [float2]()
//        let per = 1.0 / Float(pathPointCount)
//        let perRate = (point2.rate - point1.rate) / Float(pathPointCount)
//        for idx in 0..<pathPointCount {
//            let t = per * Float(idx)
//            var point = VertexPoint.init(position: float2([(pow(1 - t, 2) * point1.position.x + 2 * t * (1 - t) * controlPoint.position.x + pow(t, 2) * point2.position.x), (pow(1 - t, 2) * point1.position.y + 2 * t * (1 - t) * controlPoint.position.y + pow(t, 2) * point2.position.y)]), rate: point1.rate + perRate * Float(idx))
//            point.isNode = point1.isNode || point2.isNode
//            points.append(point)
//        }
        return points
        
    }
    
    func _ly_linePathPoint(startPoint: float2, endPoint: float2) -> [float2] {
        
        var result = [float2].init()
        let l = length(endPoint - startPoint)
        let countF = ceil(l / 4.0)
        let perX = (endPoint.x - startPoint.x) / countF
        let perY = (endPoint.y - startPoint.y) / countF
        if countF <= 0 {
            return result
        }
        for idx in 1...Int(countF) {
            result.append(startPoint + float2(perX * Float(idx), perY * Float(idx)))
        }
        return result
        
    }


}

