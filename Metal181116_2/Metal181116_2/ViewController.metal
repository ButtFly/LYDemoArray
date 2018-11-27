//
//  ViewController.metal
//  Metal181116_2
//
//  Created by 余河川 on 2018/11/16.
//  Copyright © 2018 余河川. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float dist(float2 point, float2 center, float radius) {
    return length(point - center) - radius;
}

float2 translateScreenPointToWorldPoint(float2 point, float2 screenSize) {
    
    return float2(2 * point.x / screenSize.x - 1, 2 * point.y / screenSize.y - 1);
    
}

struct Vertex {
    float x;
};

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    uint2 gid [[thread_position_in_grid]])
{
    int width = output.get_width();
    int height = output.get_height();
    float2 point = float2(gid.x, gid.y);
    float distToCircle = dist(point, float2(0.5 * width, 0.5 * height), 0.25 * width);
    float distToCircle2 = dist(point, float2(0.4 * width, 0.6 * height), 0.25 * width);
    bool inside = distToCircle2 < -1;
    bool outside = distToCircle2 >= 0;
    if (inside) {
        output.write(float4(0), gid);
    } else if (outside) {
        output.write(float4(1, 0.7, 0, 1) * (1 - distToCircle / pow(width * width + height * height, 0.5)), gid);
    } else {
        output.write(float4(0.5, 0.35, 0, 1), gid);
    }
    
}

