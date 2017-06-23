//
//  CameraController.h
//  ULSeeWrapper
//
//  Created by sukhjeet singh sandhu on 17/05/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface CameraController : NSObject

+ (CameraController*) defaultControllerWithFrontCamera:(BOOL)isFrontCamera;

- (NSString*) setSessionPreset:(NSString*) preset;

- (void) start;
- (void) stop;

- (void) startFaceDetection;
- (void) stopFaceDetection;


// delegates for image capture and face detection
@property (readwrite, strong) id<AVCaptureVideoDataOutputSampleBufferDelegate> captureDelegate;
@property (readwrite, strong) id<AVCaptureMetadataOutputObjectsDelegate> faceDetectionDelegate;

@property (readonly, nonatomic) dispatch_queue_t cameraQueue;
@property (readonly, nonatomic) dispatch_queue_t metadataQueue;
@property (readonly, assign) CGSize imageSize;
@property (readonly, assign) AVCaptureVideoOrientation orientation;
@property (assign, nonatomic) BOOL isFrontCamera;

@end
