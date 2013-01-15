//
//  ViewController.h
//  AVFCamera
//
//  Created by 永倉 啓太 on 2013/01/15.
//  Copyright (c) 2013年 永倉 啓太. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	BOOL isRequireTakePhoto;
	BOOL isProcessingTakePhoto;
	void *bitmap;
	
	AVCaptureSession *session;
	AVCaptureStillImageOutput *stillImageOutput;
	AVCaptureVideoPreviewLayer *previewLayer;
}

@property (nonatomic, retain) UIImage *imageBuffer;

@end
