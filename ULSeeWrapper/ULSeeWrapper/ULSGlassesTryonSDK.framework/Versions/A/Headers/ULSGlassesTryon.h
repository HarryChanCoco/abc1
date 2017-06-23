//
//  ULSFaceTracker.h
//  ULSFaceTracker
//
//  Created by NewWay on 8/14/14.
//  Copyright (c) 2014 ULSee Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/CAEAGLLayer.h>
#import <UIKit/UIKit.h>

@interface ULSFaceTracker : NSObject

/*
 Initialize the ULSFaceTracker class with the model file path and
 valid customer activation key.
 */
- (id)initWithModelPath:(NSString*)modelPath
        withActivateKey:(NSString*)activateKey;

/*  This function gets facial tracking result from an input image captured by
 camera. This function should be called in each new frame generating.
 
 videoFrame:The CVImageBufferRef-format frame captured from the camera. This
 frame is used to do the facial tracking process.
 
 isStartFaceTracking: A Boolean value used to determine whether to start the
 facial tracking or not.
 
 faceRectangle: The face rectangle value which returned from the method of
 AVCaptureMetadataOutputObjectsDelegate
 
 rollAngle: The roll angle value of the tracking face. This value would be got
 from the method of AVCaptureMetadataOutputObjectsDelegate. */
- (int)startFacialTracking:(CVImageBufferRef)videoFrame
         startFaceTracking:(BOOL)isStartFaceTracking
         withFaceRectangle:(CGRect)faceRectangle
             withRollAngle:(float)rollAngle;

/*  Get the number of tracked facial landmarkers. */
- (unsigned int)getNumberOfPoints;

/*  Get the (x, y) coordinates of 66 tracked landmarks in raw data,
 [x1,y1,x2,y2,…,x66,y66].*/
- (const float *)getShape;

/*  Get the scale of the tracked face which relates to the initial model. */
- (float)getScaleInImage;

/*  Get the real time pitch, yaw, roll value of the tracking face. */
- (BOOL)getRotationPitch:(float*)pitch Yaw:(float*)yaw Roll:(float*)roll;

/*  Get fps (number of frames per second) value while running the facial tracking process.*/
- (float)getFPS;

/*  Delete all the objects which are allocated from class ULSFaceTracker. */
- (void)deleteTrackerObjects;

- (void)startTrackingCreditCard:(BOOL)isStartTrackingCard;

@end

/* Protocol for PD calculation. There is just one method that must be implemented to notify that PD calculation is done. */
@protocol PDCalculateDelegate <NSObject>
@required
-(void) pdCalculateDone;            // The PD calculation is done. Call [getPDValue] to get the pupil distance value.
-(void) blackStripeDetected;        // The card black stripe is detected.
@end

/*  Class for glasses rendering */
@interface ULSGlassesRender : NSObject
/* The PD calculation delegate */
@property (weak, nonatomic) id<PDCalculateDelegate> pdCalculateDelegate;

/*  init ULSGlassesRender class */
- (id)init;

/*  This function is used to set the tracker object to the render object, for using the internal parameters correctly. This function has to be called after the ULSGlassesRender lib is initialized.
    
    theTracker : is the ULSFaceTracker object */
- (void)setTrackerLibObject:(ULSFaceTracker *)theTracker;

/*  This function is called in the UIView that is applied for rendering the camera images to initialize the OpenGL parameters. */
- (void)initialiseOpenGLWithLayer:(CAEAGLLayer *)theLayer;

/*  This function is used to render the pictures that are captured from camera.
    pixelBuffer : The CVPixelBufferRef-format frame captured from the camera. This
    frame is used to do the facial tracking process.
	
    isShowingTrackingPoint :This parameter should be set to YES when you want to 
    show the facial tracking points. Otherwise the parameter should be set to NO.
 */
- (void)drawSceneWithBackground:(CVPixelBufferRef)pixelBuffer
              showTrackingPoint:(BOOL)isShowingTrackingPoint;

/*  This function is used to render the pictures that are captured from camera.
    pixelBuffer : The CVPixelBufferRef-format frame captured from the camera. This 
    frame is used to do the facial tracking process.
	
    isShowingGlasses :This parameter should be set to YES when you want to show 
    the glasses. Otherwise the parameter should be set to NO.
 */
- (void)drawSceneWithBackground:(CVPixelBufferRef)pixelBuffer
                    showGlasses:(BOOL)isShowingGlasses;

/*  Set the image and the real size width (mm) of the glasses accessories.
    The realGlassesSize parameter is using for applying the actual glasses size in the virtual try-on screen.
    If realGlassesSize parameter is set bigger thon 0.0f, the glasses scale would be calculated by referring the realGlassesSize and the PD value.
*/
//    EX:
//    UIImage *image1 = [UIImage imageNamed:@”glasses.png”];
//    UIImage *image2 = [UIImage imageNamed:@”glasses_left_leg.png”];
//    UIImage *image3 = [UIImage imageNamed:@”glasses_right_leg.png”];
//    UIImage *image4 = [UIImage imageNamed:@”optical_lense.png”];
//    UIImage *image5 = [UIImage imageNamed:@”env.png”];
//    UIImage *image6 = [UIImage imageNamed:@”glasses_shadow.png”];
//    float glaseeRealSize = 150.f;
//
//    [renderLib setGlassesAccessoryImage:image1
//               leftSpectacleFramesImage:image2
//              rightSpectacleFramesImage:image3
//                     opticalLensesImage:image4
//                       environmentImage:image5
//                     glassesShadowImage:image6
//                        realGlassesSize:glaseeRealSize];
- (void)setGlassesAccessoryImage:(UIImage*)theImage1
        leftSpectacleFramesImage:(UIImage*)theImage2
       rightSpectacleFramesImage:(UIImage*)theImage3
              opticalLensesImage:(UIImage*)theImage4
                environmentImage:(UIImage*)theImage5
              glassesShadowImage:(UIImage*)theImage6
                 realGlassesSize:(float)theSize;

/*  This function is to set the glasses transparency if you apply the correct optical lenses image file. 
    This method is useless if you do not apply the optical lenses image file. */
- (void)setGlassesTransparency:(float)value;

/*  Set the glasses scale. */
//  EX:
//	[renderLib setGlassesScale:0.75f];
- (void)setGlassesScale:(float)value;

/*  Set the glasses pitch offset. It can be used to adjust the glasses leg position. The vaule is in degree, and 
    default is 0 degree */
//  EX:
//	[renderLib setGlassesPitchOffset:5.0f];
- (void)setGlassesPitchOffset:(float)value;

/*  Start moving the virtual glasses up or down. */
//  EX:
//  [renderLib startMoveGlasses];
- (void)startMoveGlasses;

/*  This function is called while the gesture is detected to move the virtual glasses position. 
    deltaX : The x-axis movement pixel of pan gesture.
	deltaY : The y-axis movement pixel of pan gesture. */
//  EX:
//	[renderLib moveGlassesDeltaX DeltaY:deltaY];
- (void)moveGlassesDeltaX:(float)deltaX DeltaY:(float)deltaY;

/*  This function is used to delete all the objects which are initialized from ULSGlassesRender class. */
//  EX:
//  [renderLib deleteRenderObjects];
- (void)deleteRenderObjects;

/* This function is used to set the default using camera. Usually using the front camera to do face tracking. But now you can set the back cemara for tracking. */
// EX:
// [renderLib setIsFrontCamera:NO];
- (void)setIsFrontCamera:(BOOL)isFrontCamera;

/* This function is called to do Pupil Distance (PD) measurement process. You can also set the border color (R, G, B value from 0.0f ~ 1.0f) of the card and the black stripe. */
- (void)startPDCalculateWithCardBorderRed:(float)CRed
                                    Green:(float)CGreen
                                     Blue:(float)CBlue
                          StripeBorderRed:(float)SRed
                                    Green:(float)SGreen
                                     Blue:(float)SBlue;
/* This function is called to get the pupil distance (mm). */
- (float)getPDValue;
/* This function is called to stop the pupil distance measurement. */
- (void)stopPDCalculate;
/* This function is called to get the card rectangle position. */
- (CGRect)getCardRectangle;
@end
