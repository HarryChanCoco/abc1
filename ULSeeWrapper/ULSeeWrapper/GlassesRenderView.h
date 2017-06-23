//
//  GlassesRenderView.h
//  ULSeeWrapper
//
//  Created by sukhjeet singh sandhu on 17/05/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ULSGlassesTryonSDK/GlassesTryon.h>

@interface GlassesRenderView : UIView
{
    ULSGlassesRender *renderLib;
}

@property (assign) BOOL isDrawingGlasses;

- (id)init:(CGRect)frame image1:(UIImage*)theImage1 image2:(UIImage*)theImage2 image3:(UIImage*)theImage3 image4:(UIImage*)theImage4 image5:(UIImage*)theImage5 image6:(UIImage*)theImage6;
- (void)initialiseOpenGL;
- (void)drawSceneWithBackground:(CVPixelBufferRef)pb;
- (void)setTrackerLib:(ULSFaceTracker*)theLib;
- (void)setGlassesAccessoryImage:(UIImage*)theImage1
         leftSpectacleFrameImage:(UIImage*)theImage2
        rightSpectacleFrameImage:(UIImage*)theImage3
              opticalLensesImage:(UIImage*)theImage4
                environmentImage:(UIImage*)theImage5
              glassesShadowImage:(UIImage*)theImage6
                 realGlassesSize:(float)theSize;
- (void)setGlassesDeltaX:(float)deltaX AndGlassesDeltaY:(float)deltaY;
- (void)startMoveGlasses;
- (void)setGlassesTransparency:(float)glassesTransparency;
- (void)setGlassesScale:(float)glassesScale;
- (void)setGlassesPitchOffset:(float)offset;
- (void)setIsFrontCamera:(BOOL)isFrontCamera;

@end
