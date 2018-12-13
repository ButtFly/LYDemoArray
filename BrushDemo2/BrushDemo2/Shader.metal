//
//  Shader.metal
//  BrushDemo2
//
//  Created by 余河川 on 2018/12/12.
//  Copyright © 2018 余河川. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void computerFunction(texture2d<float, access::write> outTexture [[texture(0)]], constant int* screenPoints [[buffer(0)]], uint2 tid [[thread_position_in_grid]]) {
    
    float4 color = float4(screenPoints[tid.y * outTexture.get_width() + tid.x]);
    outTexture.write(color / 255.0f, tid);
}
