//
//  ViewController.swift
//  BrushDemo1
//
//  Created by 余河川 on 2018/11/16.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import MetalKit
import simd

extension CGPoint {
    var vector: float2 {
        get {
            return float2.init(Float(x), Float(y))
        }
    }
}

class ViewController: UIViewController, MTKViewDelegate {
    

    struct Vertex {
        var position: float4
        var color: float4
    }
    
    struct VertexPoint {
        
        /// 位置
        var position: float2
        
        /// 速率
        var rate: Float
        
        /// 是否是端点
        var isNode = false
        
        init(currentPoint: float2, lastPoint: float2, time: Float) {
            self.position = float2([Float(currentPoint.x), Float(currentPoint.y)])
            self.rate = sqrtf(powf(Float(currentPoint.x - lastPoint.x), 2) + powf(Float(currentPoint.y - lastPoint.y), 2)) / time
        }
        
        init(position: float2, rate: Float) {
            self.position = position
            self.rate = rate
        }
        
    }
    
    let mtkView = MTKView.init(frame: CGRect.zero)
    var rpls: MTLRenderPipelineState?
    var points = [VertexPoint].init()
    var touchPoints = [VertexPoint].init()
    var centerPoints = [VertexPoint].init()
    var drawCount = 0
    var button = UIButton.init(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        mtkView.device = MTLCreateSystemDefaultDevice()
        view.addSubview(mtkView)
        mtkView.delegate = self
        mtkView.isOpaque = false
        mtkView.colorPixelFormat = .rgba16Float
        mtkView.clearColor = MTLClearColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //        self.autoresizingMask = [View.AutoresizingMask.flexibleWidth, View.AutoresizingMask.flexibleHeight]
        mtkView.framebufferOnly = true
        // Run with 4x MSAA:
        mtkView.sampleCount = 4
        mtkView.preferredFramesPerSecond = 60
        
        self.view.addSubview(self.button)
        self.button.setTitle("U", for: .normal)
        self.button.addTarget(self, action: #selector(updateBtnClick(sender:)), for: .touchUpInside)
        self.button.setTitleColor(UIColor.green, for: .normal)
        
        let library = mtkView.device?.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "myVertextFunction")
        let fragmentFunction = library?.makeFunction(name: "myFragmentFunction")
        let rpld = MTLRenderPipelineDescriptor.init()
        rpld.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        rpld.colorAttachments[0].isBlendingEnabled = true
        rpld.colorAttachments[0].rgbBlendOperation = .add
        rpld.colorAttachments[0].alphaBlendOperation = .add
        rpld.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        rpld.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        rpld.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        rpld.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        rpld.vertexFunction = vertexFunction
        rpld.fragmentFunction = fragmentFunction
        rpld.sampleCount = 4
        rpls = try! mtkView.device?.makeRenderPipelineState(descriptor: rpld)
    }
    
    override func viewWillLayoutSubviews() {
        
        mtkView.frame = view.bounds
        self.button.frame = CGRect.init(origin: CGPoint.init(x: 20, y: 40), size: CGSize.init(width: 44, height: 44))
        
    }
    
    @objc func updateBtnClick(sender: UIButton) -> Void {
        points.removeAll()
        touchPoints.removeAll()
        centerPoints.removeAll()
    }
    
    func createVertexs(points: [VertexPoint]) -> [Vertex] {
        
        var vertexs = [Vertex]()
        var width:Float!
        for (idx, _) in points.enumerated() {
            
            if idx == 0 {
                continue
            }
            let point_b = points[idx]
            let point_a = points[idx - 1];
            var vector: float2!
            if idx == 1 {
                vector = normalize(point_b.position - point_a.position)
            } else {
                let point_o = points[idx - 2]
                vector = normalize(normalize(point_b.position - point_a.position) + normalize(point_a.position - point_o.position))
            }
            width = -5.32 * powf(point_b.rate, 0.25) + 20
            
            var brush_width = Float(1.0)
            if idx < 20 {
                brush_width = Float(0.05 * Float(idx))
            }
            
            if idx >= points.count - 20 {
                brush_width = Float(20 - (idx - (points.count - 20))) * 0.05
            }
            
            width = width < 1 ? 1 : width
            width = width > 20 ? 20 : width
            width *= brush_width
            let cz_vector = float2([-vector.y, vector.x])
            let color = point_b.isNode ? float4([0.0, 0.0, 0.0, 0.0]) : float4([1.0, 1.0, 0.0, 1.0])
            if idx == 1 {
                let pa = point_a.position + 0.5 * width * cz_vector
                let pb = point_a.position - 0.5 * width * cz_vector
                vertexs.append(Vertex.init(position: float4([pa.x, pa.y, 0.0, 1.0]), color: color))
                vertexs.append(Vertex.init(position: float4([pb.x, pb.y, 0.0, 1.0]), color: color))
            }
            let pa = point_b.position + width * cz_vector
            let pb = point_b.position - width * cz_vector
            vertexs.append(Vertex.init(position: float4([pa.x, pa.y, 0.0, 1.0]), color: color))
            vertexs.append(Vertex.init(position: float4([pb.x, pb.y, 0.0, 1.0]), color: color))
            
        }
        return vertexs
        
    }
    
    func translateScreenPointToWorldPoint(point: CGPoint) -> Vertex {
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        return Vertex.init(position: float4.init(Float(point.x / (0.5 * screenWidth) - 1), -Float(point.y / (0.5 * screenHeight) - 1), 0, 1), color: float4.init(1.0, 0.0, 0.0, 1.0))
        
    }
    
    func draw(in view: MTKView) {
        
        if drawCount == points.count {
            return
        }
        guard let drawable = view.currentDrawable else {
            return;
        }
        guard let rpd = view.currentRenderPassDescriptor else {
            return;
        }
        let commendQueue = view.device?.makeCommandQueue()
        let commendBuffer = commendQueue?.makeCommandBuffer()
        guard let renderCommandEncoder = commendBuffer?.makeRenderCommandEncoder(descriptor: rpd)  else {
            return
        }
        if points.count > 1  {
            let vertexs = createVertexs(points: points)
            let vertexBuffer = view.device?.makeBuffer(bytes: vertexs, length: MemoryLayout<Vertex>.size * vertexs.count, options: [])
            let screenBuffer = view.device?.makeBuffer(length: MemoryLayout<float2>.size, options: [])
            var size = float2.init(Float(UIScreen.main.bounds.size.width), Float(UIScreen.main.bounds.size.height))
            memcpy(screenBuffer?.contents(), &size, MemoryLayout<float2>.size)
            renderCommandEncoder.setRenderPipelineState(rpls!)
            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(screenBuffer, offset: 0, index: 1)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexs.count)
        }
        renderCommandEncoder.endEncoding()
        commendBuffer?.present(drawable)
        commendBuffer?.commit()
        drawCount = points.count
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: mtkView) else {
            return
        }
        lineAddPoint(point: point, isNode: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: mtkView) else {
            return
        }
        lineAddPoint(point: point)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: mtkView) else {
            return
        }
        lineAddPoint(point: point, isNode: true)
        
    }
    
    func lineAddPoint(point: CGPoint, isNode: Bool = false) -> Void {
        
        var currentVPoint: VertexPoint?
        if let lastPoint = touchPoints.last {
            currentVPoint = VertexPoint.init(currentPoint: point.vector, lastPoint: lastPoint.position, time: 1)
            currentVPoint?.isNode = isNode
            centerPoints.append(centerPoint(point1: lastPoint, point2: currentVPoint!))
        }

        if currentVPoint == nil {
            currentVPoint = VertexPoint.init(position: point.vector, rate: Float(0))
            currentVPoint?.isNode = isNode
        }
        
        touchPoints.append(currentVPoint!)
        
        if centerPoints.count > 2 {
            
            let idx = centerPoints.count - 1
            let lastPoints = besselPathPoints(point1: centerPoints[idx - 1], point2: centerPoints[idx], controlPoint: touchPoints[idx])
            points += lastPoints
            
        }
        
    }
    
    func centerPoint(point1: VertexPoint, point2: VertexPoint) -> VertexPoint {
        
        var result = VertexPoint.init(position: float2([point1.position.x * 0.5 + point2.position.x * 0.5, point1.position.y * 0.5 + point2.position.y * 0.5]), rate: 0.5 * point1.rate + 2.5 * point2.rate)
        result.isNode = point1.isNode && point2.isNode
        return result
        
    }
    
    func besselPathPoints(point1: VertexPoint, point2: VertexPoint, controlPoint: VertexPoint) -> [VertexPoint] {
        
        let pathPointCountF = roundf(sqrtf(powf(Float(point2.position.x - point1.position.x), 2) + powf(Float(point2.position.y - point1.position.y), 2)))
        let pathPointCount = UInt(pathPointCountF)
        var points = [VertexPoint]()
        let per = 1.0 / Float(pathPointCount)
        let perRate = (point2.rate - point1.rate) / Float(pathPointCount)
        for idx in 0..<pathPointCount {
            let t = per * Float(idx)
            var point = VertexPoint.init(position: float2([(pow(1 - t, 2) * point1.position.x + 2 * t * (1 - t) * controlPoint.position.x + pow(t, 2) * point2.position.x), (pow(1 - t, 2) * point1.position.y + 2 * t * (1 - t) * controlPoint.position.y + pow(t, 2) * point2.position.y)]), rate: point1.rate + perRate * Float(idx))
            point.isNode = point1.isNode || point2.isNode
            points.append(point)
        }
        return points
        
    }

}

