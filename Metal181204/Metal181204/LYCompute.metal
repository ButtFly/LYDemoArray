//
//  LYCompute.metal
//  Metal181204
//
//  Created by 余河川 on 2018/12/4.
//  Copyright © 2018 余河川. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void computeFunction(texture2d<float, access::write> out [[texture(0)]], texture2d<float, access::sample> in [[texture(1)]], uint2 tid [[thread_position_in_grid]], uint2 gid [[threadgroup_position_in_grid]], constant uint &time [[buffer(0)]]) {
    
    float2 inSize = float2(in.get_width(), in.get_height()) * 2.0f;
    float2 outSize = float2(out.get_width(), out.get_height());
    float2 offset = float2(outSize.x - inSize.x, outSize.y - inSize.y) * 0.5;
    float4 color = float4(1);
    float2 location = float2(tid.x, tid.y);
    float2 center = float2(outSize.x ,outSize.y) * 0.5;
    float2 r_v = location - center;
    float r = length(r_v);
    
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear );
    float3 norm = float3(r_v, sqrt(r * r - dot(r_v, r_v)));
    float pi = 3.14;
    float s = atan2( norm.z, norm.x ) / (2 * pi);
    float t = asin( norm.y ) / (2 * pi);
    t += (0.5 * inSize);
    
    if (r <= 200) {
        
        color = in.sample(textureSampler, float2(s + time * 0.1, t));
    }
    out.write(color, tid);
    
}
