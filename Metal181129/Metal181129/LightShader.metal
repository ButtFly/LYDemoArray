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

float random(float2 p) {
    return fract(dot(normalize(p), float2(40, 60)));
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float bottom = mix(random(i + float2(0)), random(i + float2(1.0, 0.0)), f.x);
    float top = mix(random(i + float2(0.0, 1.0)), random(i + float2(1)), f.x);
    float t = mix(bottom, top, f.y);
    return t;
}



float fbm(float2 uv) {
    float sum = 1;
    for (int i = 0; i < 2; i ++) {
        uv += float2(0.7 * i, 0.2);
        float x = noise(uv);
        sum *= -4 * (x - 0.5) * (x - 0.5) + 1;
    }
    return sum;
}


kernel void ls_compute(texture2d<float, access::write> output [[texture(0)]], uint2 tid [[thread_position_in_grid]], uint2 gid [[threadgroup_position_in_grid]], constant uint &timer [[buffer(0)]]) {
    
    float timer_f = timer / 100.0f;
    uint scale = tid.x / gid.x;
    float width = output.get_width();
    float height = output.get_height();
    float2 location = float2(tid.x, tid.y);
    float2 center = float2(width / 2.0f, height / 2.0f);
    float p_length = length(location - center);
//    float z = sqrt(pow(100.0 * scale, 2) - pow(location.x - center.x, 2) - pow(location.y - center.y, 2));
//    float3 normal = normalize(float3(location.x - center.x, location.y - center.y, z));
//    float3 source = normalize(float3(400 * cos(timer_f), 400 * sin(timer_f), 400));
//    float light = dot(normal, source);
//    float3 color = p_length > 100 * scale ? float3(0) : light;
//    output.write(float4(color, 1), tid);
    float distance = p_length - 100.0 * scale;
    float2 n_location = fmod(location + float2(timer_f * 100, timer_f * 40), float2(width * 100, height * 40));
    float t = fbm(n_location / float2(width, height) * 3);
    output.write(distance < 0 ? float4(float3(t), 1) : float4(0), tid);

}
