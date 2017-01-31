//
//  Vertex.swift
//  HelloMetal
//
//  Created by Alexey Levashov on 1/23/17.
//  Copyright © 2017 Alexey Levashov. All rights reserved.
//

struct Vertex{
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
    
};
