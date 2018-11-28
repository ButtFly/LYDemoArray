//
//  ViewController.metal
//  Metal181123
//
//  Created by 余河川 on 2018/11/23.
//  Copyright © 2018 余河川. All rights reserved.
//

#include <metal_stdlib>


using namespace metal;

//float2 translateScreenPointToWorldPoint(float2 point, float2 screenSize) {
//    
//    return float2(2 * point.x / screenSize.x - 1, 2 * point.y / screenSize.y - 1);
//    
//}
//
//float smootherstep(float x) {
//    return x * x * x * (x * (x * 6 - 15) + 10);
//}

//kernel void drawPoints(texture2d<float, access::write> output [[texture(0)]],
//                    uint2 gid [[thread_position_in_grid]]) {
//
//    int width = output.get_width();
//    int height = output.get_height();
//    float r = 0.4 * width;
//    float2 point = float2(gid.x, gid.y);
//    float2 cv_point = point - float2(0.5 * width, 0.5 * height);
//    float3 color;
//    float c1 = cv_point.y - (pow(3.0, 0.5) * cv_point.x + r);
//    float c2 = cv_point.y - (- pow(3.0, 0.5) * cv_point.x + r);
//    float c3 = (-0.5 * r) - cv_point.y;
//    float c4 = (- pow(3.0, 0.5) * cv_point.x - r) - cv_point.y;
//    float c5 = (pow(3.0, 0.5) * cv_point.x - r) - cv_point.y;
//    float c6 = cv_point.y - (0.5 * r);
//
//    if ((c1 < -20 && c2 < -20 && c3 < -20 * 0.5) || (c4 < -20 && c5 < -20 && c6 < -20 * 0.5)) {
//        color = float3(0.7);
//    } else if (!(c1 < 0 && c2 < 0 && c3 < 0) && !(c4 < 0 && c5 < 0 && c6 < 0)) {
//        color = float3(0);
//    } else {
////        float min_c = abs(c1) < abs(c2) ? abs(c1) : abs(c2);
////        min_c = min_c < abs(c3 * 0.5) ? min_c : abs(c3 * 0.5);
////        min_c = min_c < abs(c4) ? min_c : abs(c4);
////        min_c = min_c < abs(c5) ? min_c : abs(c5);
////        min_c = min_c < abs(c6 * 0.5) ? min_c : abs(c6 * 0.5);
////        color = float3(0.3, 0.3, 0.3) * min_c * 0.05;
////        color = float3(1.0, 0, 0) * min_c * 0.5;
//        color = float3(1.0, 0, 0);
//    }
//    output.write(float4(color, 1), gid);
//
//}

kernel void drawPoints(texture2d<float, access::write> output [[texture(0)]],
                       uint2 gid [[thread_position_in_grid]]) {

    int width = output.get_width();
    int height = output.get_height();
    float2 uv = float2(gid) / float2(width, height);
    uv = uv * 2.0 - 1.0;
    float2 cc = 1.1*float2( 0.5*cos(0.1) - 0.25*cos(0.2), 0.5*sin(0.1) - 0.25*sin(0.2) );
    float4 dmin = float4(1000.0);
    float2 z = (-1.0 + 2.0*uv)*float2(1.7,1.0);
    for( int i=0; i<64; i++ ) {
        z = cc + float2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
        dmin=min(dmin, float4(abs(0.0+z.y + 0.5*sin(z.x)), abs(1.0+z.x + 0.5*sin(z.y)), dot(z,z), length( fract(z)-0.5) ) );
    }
    float3 color = float3( dmin.w );
    color = mix( color, float3(1.00,0.80,0.60), min(1.0,pow(dmin.x*0.25,0.20)) );
    color = mix( color, float3(0.72,0.70,0.60), min(1.0,pow(dmin.y*0.50,0.50)) );
    color = mix( color, float3(1.00,1.00,1.00), 1.0-min(1.0,pow(dmin.z*1.00,0.15) ));
    color = 1.25*color*color;
    color *= 0.5 + 0.5*pow(16.0*uv.x*(1.0-uv.x)*uv.y*(1.0-uv.y),0.15);
    output.write(float4(color, 1), gid);
    
}

