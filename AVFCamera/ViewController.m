//
//  ViewController.m
//  AVFCamera
//
//  Created by 永倉 啓太 on 2013/01/15.
//  Copyright (c) 2013年 永倉 啓太. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSError *error = nil;
    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
		
    }
    if(!deviceInput){
		
    }
    if ( [session canAddInput:deviceInput] ){
        [session addInput:deviceInput];
    }else{
		
    }
	
    stillImageOutput = [AVCaptureStillImageOutput new];
    if ( [session canAddOutput:stillImageOutput] ){
        [session addOutput:stillImageOutput];
    }else{
		
    }
	
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor redColor] CGColor]];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
	
    UIView *previewView = [[UIView alloc] initWithFrame:CGRectMake(0,  0, 320, 427)];
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    [self.view addSubview:previewView];
	
    [session startRunning];
	
	UIButton *shutterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	shutterButton.frame = CGRectMake(100, 20, 200, 20);
	[shutterButton setTitle:@"shutter" forState:UIControlStateNormal];
	[shutterButton addTarget:self action:@selector(shutter:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:shutterButton];
	
	/*
	
	//image init
	size_t width = 640;
	size_t height = 480;
	bitmap = malloc(width * height * 4);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, bitmap, width * height * 4, NULL);
	CGImageRef cgImage = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, dataProviderRef, NULL, 0, kCGRenderingIntentDefault);
	self.imageBuffer = [UIImage imageWithCGImage:cgImage];
	CGColorSpaceRelease(colorSpace);
	CGDataProviderRelease(dataProviderRef);
	
	//self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
	AVCaptureSession *captureSession;
	AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	[captureSession addOutput:videoOutput];
	
	videoOutput.alwaysDiscardsLateVideoFrames = YES;
	dispatch_queue_t queue = dispatch_queue_create("com.overout223.myQueue", NULL);
	[videoOutput setSampleBufferDelegate:self
								   queue:queue];
	//dispatch_release(queue);
	*/
	
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)shutter:(id)sender{
	//このメソッドを呼べばUIImage imageの中にデータが入ります！
	//このサンプルでは保存までしてます。
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureVideoOrientation avcaptureOrientation = AVCaptureVideoOrientationPortrait;
	
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:1];
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey]];
    [stillImageOutput
     captureStillImageAsynchronouslyFromConnection:stillImageConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (error) {
			 NSLog(@"error");
         }
		 NSLog(@"correct");
         NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
		 UIImage *image = [[UIImage alloc] initWithData:jpegData];
		 UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
     }
     ];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
	
    if (isRequireTakePhoto) {
		
        isRequireTakePhoto = NO;
        isProcessingTakePhoto = YES;
		
        CVPixelBufferRef pixbuff = CMSampleBufferGetImageBuffer(sampleBuffer);
		
        if(CVPixelBufferLockBaseAddress(pixbuff, 0) == kCVReturnSuccess){
			
            memcpy(bitmap, CVPixelBufferGetBaseAddress(pixbuff), 640 * 480 * 4);
			
            CMAttachmentMode attachmentMode;
            CFDictionaryRef metadataDictionary = CMGetAttachment(sampleBuffer, CFSTR("MetadataDictionary"), &attachmentMode);
			
            // フォトアルバムに保存
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
			
            [library writeImageToSavedPhotosAlbum:self.imageBuffer.CGImage
                                         metadata:(NSDictionary *)CFBridgingRelease(metadataDictionary)
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      
                                      NSLog(@"URL:%@", assetURL);
                                      NSLog(@"error:%@", error);
                                      isProcessingTakePhoto = NO;
                                  }];
			
            CVPixelBufferUnlockBaseAddress(pixbuff, 0);
		}
	}
}

@end
