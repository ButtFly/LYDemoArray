//
//  ViewController.m
//  MetalHello
//
//  Created by 余河川 on 2018/11/12.
//  Copyright © 2018 余河川. All rights reserved.
//

#import "ViewController.h"
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

/**
 <#Description#>
 */
@property (nonatomic, strong) MTKView *mtkView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (device == nil) {
        NSLog(@"不支持的设备");
        return ;
    }
    
    self.mtkView = [[MTKView alloc] initWithFrame:CGRectZero device:device];
    [self.view addSubview:_mtkView];
    _mtkView.frame = self.view.bounds;
    
    id<MTLCommandQueue> queue = device.newCommandQueue;
    
    id<MTLCommandBuffer> buffer = [queue commandBuffer];
    
    
    static const float vertexArrayData[] = {
        
        0.577, -0.25, 0.0, 1.0,
        -0.577, -0.25, 0.0, 1.0,
        0.0, 0.5, 0.0, 1.0
        
    };
    
    id<MTLBuffer> vertexBuffer = [device newBufferWithBytes:vertexArrayData length:sizeof(vertexArrayData) options:0];
    
    UIImage *image = [UIImage imageNamed:@"orgin"];
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:device];
    NSError *err = nil;
    id<MTLTexture> texture = [loader newTextureWithCGImage:image.CGImage options:nil error:&err];
    
    MTLRenderPipelineDescriptor *des = [MTLRenderPipelineDescriptor new];
    id<MTLLibrary> library = [device newDefaultLibrary];
    des.vertexFunction =  [library newFunctionWithName:@"myVertexShader"];
    des.fragmentFunction = [library newFunctionWithName:@"myFragmentShader"];
    des.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    NSError *error;
    id <MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:des error:&error];
    
    CAMetalLayer *metalLayer = (CAMetalLayer*)[_mtkView layer];
    id<CAMetalDrawable> drawable = [metalLayer nextDrawable];
    
    MTLRenderPassDescriptor *renderDes = [MTLRenderPassDescriptor new];
    renderDes.colorAttachments[0].texture = drawable.texture;
    renderDes.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderDes.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderDes.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.65, 0.8, 1); //background color
    
    
    //command encoder
    id<MTLRenderCommandEncoder> encoder = [buffer renderCommandEncoderWithDescriptor:renderDes];
    [encoder setCullMode:MTLCullModeNone];
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:pipelineState];
    [encoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [encoder setFragmentTexture:texture atIndex:0];
    
    //set render vertex
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle
                vertexStart:0
                vertexCount:3];
    
    [encoder endEncoding];
    
    //commit
    [buffer presentDrawable:drawable];
    [buffer commit];
    
}




@end
