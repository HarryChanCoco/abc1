//
//  GlassesRenderView.m
//  ULSeeWrapper
//
//  Created by sukhjeet singh sandhu on 17/05/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

#import "GlassesRenderView.h"

@interface GlassesRenderView () {

    UIImage *frameOfGlass;
    UIImage *leftTemple;
    UIImage *rightTemple;
    UIImage *leftLens;
    UIImage *rightLens;
    UIImage *shadowOfGlass;
}

@end

@implementation GlassesRenderView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)initLayer
{
    CAEAGLLayer* l = (CAEAGLLayer*) self.layer;
    l.opaque = YES;
    l.drawableProperties= [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                           kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                           nil];
}

- (id)init:(CGRect)frame image1:(UIImage*)theImage1 image2:(UIImage*)theImage2 image3:(UIImage*)theImage3 image4:(UIImage*)theImage4 image5:(UIImage*)theImage5 image6:(UIImage*)theImage6
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initLayer];
        renderLib = [[ULSGlassesRender alloc] init];
        [renderLib setGlassesAccessoryImage:theImage1
                   leftSpectacleFramesImage:theImage2
                  rightSpectacleFramesImage:theImage3
                         opticalLensesImage:theImage4
                           environmentImage:theImage5
                         glassesShadowImage:theImage6
                            realGlassesSize:145.0f];
        self.isDrawingGlasses = YES;
    }
    return self;
}


- (void)dealloc {
    
}

- (void)initialiseOpenGL
{
    [renderLib initialiseOpenGLWithLayer:(CAEAGLLayer*)self.layer];
}

- (void)drawSceneWithBackground:(CVPixelBufferRef)pb
{
    if( renderLib == nil )
        return;
    [renderLib drawSceneWithBackground:pb showGlasses:self.isDrawingGlasses];
}

- (void)setTrackerLib:(ULSFaceTracker*)theLib
{
    [renderLib setTrackerLibObject:theLib];
}

- (void)setGlassesAccessoryImage:(UIImage*)theImage1
         leftSpectacleFrameImage:(UIImage*)theImage2
        rightSpectacleFrameImage:(UIImage*)theImage3
              opticalLensesImage:(UIImage*)theImage4
                environmentImage:(UIImage*)theImage5
              glassesShadowImage:(UIImage *)theImage6
                 realGlassesSize:(float)theSize
{
    [renderLib setGlassesAccessoryImage:theImage1
               leftSpectacleFramesImage:theImage2
              rightSpectacleFramesImage:theImage3
                     opticalLensesImage:theImage4
                       environmentImage:theImage5
                     glassesShadowImage:theImage6
                        realGlassesSize:theSize];
}

- (void)setGlassesDeltaX:(float)deltaX AndGlassesDeltaY:(float)deltaY
{
    [renderLib moveGlassesDeltaX:deltaX DeltaY:deltaY];
}

- (void)startMoveGlasses
{
    [renderLib startMoveGlasses];
}

- (void)setGlassesTransparency:(float)glassesTransparency
{
    [renderLib setGlassesTransparency:glassesTransparency];
}

- (void)setGlassesScale:(float)glassesScale
{
    [renderLib setGlassesScale:glassesScale];
}

- (void)setGlassesPitchOffset:(float)offset
{
    [renderLib setGlassesPitchOffset:offset];
}

- (void)setIsFrontCamera:(BOOL)isFrontCamera
{
    [renderLib setIsFrontCamera:isFrontCamera];
}

@end
