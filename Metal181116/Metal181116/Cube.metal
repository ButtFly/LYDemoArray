//
//  Cube.metal
//  Metal181116
//
//  Created by 余河川 on 2018/11/16.
//  Copyright © 2018 余河川. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    
    float4 position [[position]];
    float4 color;
    
};

struct  Uniforms {
    float4x4 matrix;
};

vertex Vertex allVertex(constant Vertex *vertexs [[buffer(0)]], constant uint *idxs [[buffer(1)]], constant Uniforms &uniforms [[buffer(2)]], uint idx [[vertex_id]]) {
    
    float4x4 matrix = uniforms.matrix;
    Vertex in = vertexs[idxs[idx]];
    Vertex out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    return out;
}

fragment float4 verTexColor(Vertex in [[stage_in]]) {
    return in.color;
}

