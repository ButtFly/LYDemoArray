//
//  Hello.metal
//  MetalHello
//
//  Created by 余河川 on 2018/11/12.
//  Copyright © 2018 余河川. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position;
    float2 texCoords;
} VertexIn;

typedef struct {
    float4 position [[position]];
    float2 texCoords;
} VertexOut;

vertex VertexOut myVertexShader(const device VertexIn* vertexArray[[buffer(0)]], unsigned int vid [[vertex_id]]) {
    
    VertexOut verout;
    verout.position = vertexArray[vid].position;
    verout.texCoords = vertexArray[vid].texCoords;
    return verout;
    
}

fragment float4 myFragmentShader(VertexOut VertexIn [[stage_in]], texture2d<float, access::sample> inputImage   [[ texture(0) ]], textureSampler [[sampler(0)]]) {
    
    float4 color = inputImage.sample(textureSampler, VertexIn.texCoords);
    return color;
    
}
