//
//  ViewController.swift
//  HelloMetal
//
//  Created by Alexey Levashov on 1/20/17.
//  Copyright © 2017 Alexey Levashov. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var objectToDraw: Cube!
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    var projectionMatrix: Matrix4!
    var lastFrameTimestamp: CFTimeInterval = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()          // 1
        metalLayer.device = device           // 2
        metalLayer.pixelFormat = .bgra8Unorm // 3
        metalLayer.framebufferOnly = true    // 4
        metalLayer.frame = view.layer.frame  // 5
        view.layer.addSublayer(metalLayer)   // 6
        
        //let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
        //vertexBuffer = device.makeBuffer(length: dataSize, options: [])
        objectToDraw = Cube(device: device)
        objectToDraw.positionX = -0.25
        objectToDraw.rotationZ = Matrix4.degrees(toRad: 45);
        objectToDraw.scale = 0.5
        
        // Add shaders from library
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")
        
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // 3
        do {
            try self.pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let pipelineError as NSError {
            print("Failed to create pipeline state, error \(pipelineError)")
        }
        
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func render() {
//        let drawable = metalLayer.nextDrawable()!
//        
//        let renderPassDescriptor = MTLRenderPassDescriptor()
//        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
//        renderPassDescriptor.colorAttachments[0].loadAction = .clear
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
//        let commandBuffer = commandQueue.makeCommandBuffer()
//
//        let renderEncoderOpt = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
//        renderEncoderOpt.setRenderPipelineState(pipelineState)
//        renderEncoderOpt.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
//        renderEncoderOpt.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
//        renderEncoderOpt.endEncoding()
//        
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        
        let worldModelMatrix = Matrix4()
        worldModelMatrix?.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix?.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable!, parentModelViewMatrix: worldModelMatrix!, projectionMatrix: projectionMatrix ,clearColor: nil)
    }
    
    // 1
    func newFrame(displayLink: CADisplayLink){
        
        if lastFrameTimestamp == 0.0
        {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        // 2
        let elapsed:CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        // 3
        gameloop(timeSinceLastUpdate: elapsed)
    }
    
    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
        
        // 4
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        
        // 5
        autoreleasepool {
            self.render()
        }
    }
}

