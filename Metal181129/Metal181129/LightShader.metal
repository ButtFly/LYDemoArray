//
//  LightShader.metal
//  Metal181129
//
//  Created by 余河川 on 2018/11/29.
//  Copyright © 2018 余河川. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float smootherstep(float x) {
    return x * x * x * (x * (x * 6 - 15) + 10);
}


kernel void ls_compute(texture2d<float, access::write> output [[texture(0)]], uint2 tid [[thread_position_in_grid]], uint2 gid [[threadgroup_position_in_grid]], constant uint &timer [[buffer(0)]]) {
    
    float timer_f = timer / 100.0f;
    uint scale = tid.x / gid.x;
    float width = output.get_width();
    float height = output.get_height();
    float2 location = float2(tid.x, tid.y);
    float2 center = float2(width / 2.0f, height / 2.0f);
    float distance = length(location - center);
    float z = sqrt(pow(100.0 * scale, 2) - pow(location.x - center.x, 2) - pow(location.y - center.y, 2));
    float3 normal = normalize(float3(location.x - center.x, location.y - center.y, z));
    float3 source = normalize(float3(400 * cos(timer_f), 400 * sin(timer_f), 400));
    float light = dot(normal, source);
    float3 color = distance > 100 * scale ? float3(0) : light;
    output.write(float4(color, 1), tid);
    
}
