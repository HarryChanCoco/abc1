//
//  ULSeeWrapperView.m
//  ULSeeWrapper
//
//  Created by sukhjeet singh sandhu on 17/05/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

#import "ULSeeWrapperView.h"
#import "GlassesRenderView.h"
#import "CameraController.h"
#import <OpenGLES/ES3/gl.h>

@interface ULSeeWrapperView ()
{
    ULSFaceTracker *trackerLib;
    CameraController *_camera;
    CGRect _faceRect;
    float _rollAngle;
    CGPoint startPosition, endPosition;
    float realGlassesSize;
    BOOL isApplyingFrontCamera;
    GlassesRenderView *trackerView;
    NSString *keyToTrack;
}

@end

@implementation ULSeeWrapperView

- (instancetype) init:(NSString*)key {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    NSLog(@"Initialized ULSeeWrapperView");
    keyToTrack = key;
    self.allowVerticalDrag = true;
    self.allowHorizontalDrag = true;
    return self;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    [trackerLib startFacialTracking:pixelBuffer
                                        startFaceTracking:YES
                                        withFaceRectangle:_faceRect
                                            withRollAngle:_rollAngle];
    
    CVPixelBufferRetain(pixelBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        [trackerView drawSceneWithBackground:pixelBuffer];
        CVPixelBufferRelease(pixelBuffer);
    });
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if([metadataObjects count] > 0) {
        AVMetadataFaceObject *face =	[metadataObjects objectAtIndex:0];
        CGRect r = [face bounds];
        CGSize sz = [_camera imageSize];
        _rollAngle = [face rollAngle] * M_PI/ 180;
        _faceRect = CGRectMake((r.origin.x)*sz.width, r.origin.y*sz.height,
                               r.size.width*sz.width, r.size.height*sz.height);
        
        //        dispatch_async( dispatch_get_main_queue(), ^(){
        //            testLabel.frame = CGRectMake(r.origin.y*sz.height*1.6, (r.origin.x)*sz.width*1.6,
        //                                         r.size.height*sz.height*1.6, r.size.width*sz.width*1.6);
        //        });
    } else {
        _faceRect = CGRectMake(-1, -1,-1,-1);
    }
}

- (void)setFrameOfGlass:(UIImage*)frame leftTemple:(UIImage*)temple1 rightTemple:(UIImage*)temple2 lens:(UIImage*)lensImage environmentImage:(UIImage*)environment shadowOfGlass:(UIImage*)shadow view:(UIView*)theView
{
    trackerView = [[GlassesRenderView alloc] init:theView.bounds image1:frame image2:temple1 image3:temple2 image4:lensImage image5:environment image6:shadow];
    [trackerView initialiseOpenGL];
    
    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
    
    NSString *path = [mainBundlePath stringByAppendingPathComponent:@"ULSFaceTrackerAssets.bundle"];
    
    trackerLib = [[ULSFaceTracker alloc] initWithModelPath:path withActivateKey:keyToTrack];
    [trackerView setTrackerLib:trackerLib];
    
    
#if TARGET_IPHONE_SIMULATOR
#else
    isApplyingFrontCamera = YES;
    [trackerView setIsFrontCamera:isApplyingFrontCamera];
    _camera = [CameraController defaultControllerWithFrontCamera:isApplyingFrontCamera];
    
    [_camera setCaptureDelegate:self];
    [_camera setFaceDetectionDelegate:self];
    [_camera startFaceDetection];
    [_camera start];
#endif
    realGlassesSize = 145.0f;
    
    [self changeGlassesFrame:frame leftTemple:temple1 rightTemple:temple2 lens:lensImage environmentImage:environment shadowOfGlass:shadow];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    [trackerView addGestureRecognizer:panGesture];
    [theView addSubview:trackerView];
}

- (void)setTransparency:(float)transparency temples:(float)theTemples scale:(float)theScale
{
    if ( transparency != -1.0 ) {
        [trackerView setGlassesTransparency:transparency];
    }
    if ( theTemples != -1.0 ) {
        [trackerView setGlassesPitchOffset:theTemples];
    }
    if ( theScale != -1.0 ) {
        [trackerView setGlassesScale:theScale];
    }
}

-(void)takeSnapshot {
    int picWidth = (int)(trackerView.frame.size.width);
    int picHeight = (int)(trackerView.frame.size.height);
        
    NSInteger myDataLength = picWidth * picHeight * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, picWidth, picHeight, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y<picHeight; y++) {
        for(int x = 0; x <picWidth * 4; x++) {
            buffer2[(picHeight-1 - y) * picWidth * 4 + x] = buffer[y * 4 * picWidth + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * picWidth;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(picWidth, picHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *takePictureImage = [UIImage imageWithCGImage:imageRef];
    UIImageWriteToSavedPhotosAlbum(takePictureImage, nil, nil, nil);
}

- (UIImagePickerController*)viewPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    return picker;
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    CGPoint curr = CGPointMake(0, 0);
    CGPoint touchedPosition;            // The current position that user touched on iPad screen
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            curr = [recognizer translationInView:trackerView];
            touchedPosition = [recognizer locationInView:trackerView];
            startPosition = [recognizer locationInView:trackerView];
            if(self.allowVerticalDrag)
                [trackerView startMoveGlasses];
            break;
        case UIGestureRecognizerStateChanged:
            curr = [recognizer translationInView:trackerView];
            touchedPosition = [recognizer locationInView:trackerView];
            
            curr = [recognizer translationInView:trackerView];
            if( curr.x <= 50 && self.allowVerticalDrag)
                [trackerView setGlassesDeltaX:curr.x AndGlassesDeltaY:curr.y];
            break;
        case UIGestureRecognizerStateEnded:
            curr = [recognizer translationInView:trackerView];
            endPosition = [recognizer locationInView:trackerView];
            if( curr.y <trackerView.bounds.size.height/5 ) {
                if( fabs(endPosition.x-startPosition.x) >= 100 && self.allowHorizontalDrag) {
                    if( endPosition.x >= startPosition.x )
                        [_delegate swipeLeft];
                    else
                        [_delegate swipeRight];
                }
            }
            
            break;
        default:
            break;
        }
}

-(void)changeGlassesFrame:(UIImage*)frame leftTemple:(UIImage*)temple1 rightTemple:(UIImage*)temple2 lens:(UIImage*)lensImage environmentImage:(UIImage*)environment shadowOfGlass:(UIImage*)shadow {
    [trackerView setGlassesAccessoryImage:frame
                  leftSpectacleFrameImage:temple1
                 rightSpectacleFrameImage:temple2
                       opticalLensesImage:lensImage
                         environmentImage:environment
                       glassesShadowImage:shadow
                          realGlassesSize:realGlassesSize];
}

-(void)switchCamera {
    [_camera stop];
    [_camera stopFaceDetection];
    [_camera setFaceDetectionDelegate:nil];
    [_camera setCaptureDelegate:nil];
    
    _camera = nil;
    
    
    CATransition *animation = [CATransition animation];
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromRight;
    [trackerView.layer addAnimation:animation forKey:nil];
    
    
    isApplyingFrontCamera = !isApplyingFrontCamera;
    [trackerView setIsFrontCamera:isApplyingFrontCamera];
    [trackerView initialiseOpenGL];
    
    _camera = [CameraController defaultControllerWithFrontCamera:isApplyingFrontCamera];
    [_camera setCaptureDelegate:self];
    [_camera setFaceDetectionDelegate:self];
    [_camera startFaceDetection];
    [_camera start];
}

@end
