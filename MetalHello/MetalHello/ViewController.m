//
//  ViewController.m
//  MetalHello
//
//  Created by 余河川 on 2018/11/12.
//  Copyright © 2018 余河川. All rights reserved.
//

#import "ViewController.h"
#import <MetalKit/MetalKit.h>

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
    
    
}


@end
