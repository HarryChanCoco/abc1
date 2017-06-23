//
//  CameraController.m
//  ULSeeWrapper
//
//  Created by sukhjeet singh sandhu on 17/05/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

#import "CameraController.h"

@interface CameraController ()

@property (readwrite) CGSize imageSize;
@property (readwrite, nonatomic) dispatch_queue_t cameraQueue;
@property (readwrite, nonatomic) dispatch_queue_t metadataQueue;

@end


@implementation CameraController
{
    AVCaptureSession * _captureSession;
    AVCaptureDevice * _captureDevice;
    AVCaptureDeviceInput * _captureInput;
    AVCaptureVideoDataOutput * _captureOutput;
    AVCaptureMetadataOutput * _metadataOutput;
}

+ (CameraController*) defaultControllerWithFrontCamera:(BOOL)isFrontCamera {
    static CameraController * controller = nil;
    static dispatch_once_t onceToken;
    
    if( controller != nil )
    {
        controller = nil;
        onceToken = 0;
    }
    
    if( controller == nil )
    {
        dispatch_once(&onceToken, ^{
            controller = [[self alloc] initWithFrontCamera:isFrontCamera];
        });
    }
    return controller;
}

// taken from http://stackoverflow.com/questions/5886719/what-is-the-front-cameras-deviceuniqueid
- (AVCaptureDevice*) frontFacingCameraWithFrontCamera:(BOOL)isFrontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *capture = nil;
    for (AVCaptureDevice *dev in devices) {
        if( isFrontCamera )
        {
            if (dev.position == AVCaptureDevicePositionFront) {
                capture = dev;
                break;
            }
        }
        else
        {
            if (dev.position == AVCaptureDevicePositionBack) {
                capture = dev;
                break;
            }
        }
    }
    if (!capture) {
        capture = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return capture;
}


- (id)initWithFrontCamera:(BOOL)isFrontCam {
    self = [super init];
    if (self) {
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if(status == AVAuthorizationStatusAuthorized) { // authorized
            NSLog( @"AVAuthorizationStatusAuthorized" );
        }
        else if(status == AVAuthorizationStatusDenied){ // denied
            NSLog( @"AVAuthorizationStatusDenied" );
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:@"You should allow the camera usage for this app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return nil;
        }
        else if(status == AVAuthorizationStatusRestricted){ // restricted
            
            NSLog( @"AVAuthorizationStatusRestricted" );
        }
        else if(status == AVAuthorizationStatusNotDetermined){ // not determined
            NSLog( @"AVAuthorizationStatusNotDetermined" );
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){ // Access has been granted ..do something
                    
                } else { // Access denied ..do something
                    
                }
            }];
        }
        
        
        _captureDevice = [self frontFacingCameraWithFrontCamera:isFrontCam];
        NSError *error;
        _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
        if (!_captureInput) {
            NSLog(@"Failed to create device input from camera: %@", [error description]);
            abort();
        }
        
        _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_captureOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil]];
        [_captureOutput setAlwaysDiscardsLateVideoFrames:YES];
        
        _captureSession = [[AVCaptureSession alloc] init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
            _imageSize = CGSizeMake(640, 480);
        } else if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [_captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
            _imageSize = CGSizeMake(1920, 1080);
        } else if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
            _imageSize = CGSizeMake(1280, 720);
        } else {
            [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
            AVCaptureDeviceFormat* format = [_captureDevice activeFormat];
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions([format formatDescription]);
            _imageSize = CGSizeMake(dimensions.width, dimensions.height);
        }
        
        [_captureSession addInput:_captureInput];
        [_captureSession addOutput:_captureOutput];
        
        //    AVCaptureConnection* connection = [_captureOutput connectionWithMediaType:AVMediaTypeVideo];
        //    if ([connection isVideoOrientationSupported]) {
        //      [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        //      NSLog(@"Video orientation supported");
        //    }
        //    if ([connection isVideoMirroringSupported]) {
        //      NSLog(@"Video mirroring supported");
        //      [connection setVideoMirrored:YES];
        //    }
        
        
        _cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
        _metadataQueue = dispatch_queue_create("metadataQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSString*) setSessionPreset:(NSString*) preset {
    if ([_captureSession canSetSessionPreset:preset]) {
        [_captureSession beginConfiguration];
        [_captureSession setSessionPreset:preset];
        [_captureSession commitConfiguration];
        
        AVCaptureDeviceFormat* format = [_captureDevice activeFormat];
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions([format formatDescription]);
        _imageSize = CGSizeMake(dimensions.height, dimensions.width);
        
        return preset;
    } else {
        return nil;
    }
}

- (void) start {
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
}

- (void) stop {
    [_captureSession stopRunning];
    [_captureDevice unlockForConfiguration];
    
    _captureSession = nil;
    _captureDevice = nil;
    _captureInput = nil;
    _captureOutput = nil;
    _metadataOutput = nil;
}

- (void) startFaceDetection {
    // 2016.03.16 NewWay added to check the AVMetadataObjectTypeFace is supported or not.
    NSArray* supportTypes =_metadataOutput.availableMetadataObjectTypes;
    
    if( [supportTypes containsObject:AVMetadataObjectTypeFace] )
        [_metadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeFace]];
    else
        NSLog( @"NOT Support AVMetadataObjectTypeFace!" );
}

- (void) stopFaceDetection {
    [_metadataOutput setMetadataObjectTypes:[NSArray array]];
}

- (AVCaptureVideoOrientation)orientation {
    return [[_captureOutput connectionWithMediaType:AVMediaTypeVideo] videoOrientation];
}


#pragma mark - delegates

- (void) setCaptureDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)captureDelegate {
    [_captureOutput setSampleBufferDelegate:captureDelegate queue:_cameraQueue];
}

- (id<AVCaptureVideoDataOutputSampleBufferDelegate>) captureDelegate {
    return [_captureOutput sampleBufferDelegate];
}

- (void) setFaceDetectionDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)faceDetectionDelegate {
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:_metadataOutput];
    [_metadataOutput setMetadataObjectsDelegate:faceDetectionDelegate queue:_metadataQueue];
}

- (id<AVCaptureMetadataOutputObjectsDelegate>)faceDetectionDelegate {
    return [_metadataOutput metadataObjectsDelegate];
}
@end
