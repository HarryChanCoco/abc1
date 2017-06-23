//
//  ULSeeWrapperView.h
//  ULSeeWrapper
//
//  Created by sukhjeet singh sandhu on 17/05/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/* This protocol should be confirmed by the viewController that is going to adapt this framework and should implement these protocol methods. In these methods it is suggested to call changeGlassesFrame method with the parameters having assets of the new glass.
 */
@protocol ChangeGlasses <NSObject>

- (void) swipeLeft;
- (void) swipeRight;

@end

@interface ULSeeWrapperView : NSObject <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
}

@property (weak) id<ChangeGlasses> delegate;

// Set these properties to false to disable vertical or horizontal drag respectively. By default these are true.
@property Boolean allowVerticalDrag;
@property Boolean allowHorizontalDrag;

/* This method is used to init the framework with the key that “ULSeeTryonGlassesSDK” framework needs.
 */
- (instancetype) init:(NSString*)key;

/* This method sets assets of frame, temple, lens, environment image (the image that will be seen on glasses, when glass is not transparent at all) and shadow of glass.The required view that will have the camera output should be passed in the “view” parameter.
 */
- (void)setFrameOfGlass:(UIImage*)frame leftTemple:(UIImage*)temple1 rightTemple:(UIImage*)temple2 lens:(UIImage*)lensImage environmentImage:(UIImage*)environment shadowOfGlass:(UIImage*)shadow view:(UIView*)theView;

/* This method is used to update the transparency, temple angle and scale of the glass. If the value should not be changed then -1.0 should be passed in the value.
 */
- (void)setTransparency:(float)transparency temples:(float)theTemples scale:(float)theScale;

/* This method should be called inside the IBAction of a button that will be used to take a snapshot of the rendered view. This image will be saved in the photo gallery of the device.
 */
- (void)takeSnapshot;

/* This method will return an instance of UIImagePickerController. This should be presented in the view controller to view the photo gallery.
 */
- (UIImagePickerController*)viewPhoto;

/* This method is used to change the glass, in order to change the glass, one should pass all the assets of the new glass. Ideally this method should be called inside protocol functions, swipeLeft and swipeRight.
 */
-(void)changeGlassesFrame:(UIImage*)frame leftTemple:(UIImage*)temple1 rightTemple:(UIImage*)temple2 lens:(UIImage*)lensImage environmentImage:(UIImage*)environment shadowOfGlass:(UIImage*)shadow;

/* This method will switch camera from front to back and vice versa.*/
-(void)switchCamera;
@end
