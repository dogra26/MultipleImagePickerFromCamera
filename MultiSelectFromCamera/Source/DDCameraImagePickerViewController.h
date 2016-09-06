//
//  CustomCameraPickerViewController.h
//  MultiSelectFromCamera
//
//  Created by Deepak Dogra on 29/08/16.
//  Copyright © 2016 Deepak Dogra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDCameraImagePickerViewController;

@protocol DDCameraImagePickerDelegate <NSObject>

@required
/**
 *  Tells the delegate that user picked the image.
 *
 *  @param picker The controller object managing the image picker interface.
 *  @param image  The image that the user picked.
 */
- (void)imagePickerController:(DDCameraImagePickerViewController *)picker didFinishPickingImage:(UIImage *)image;

@optional
/**
 *  Tells the delegate that the user tapped on cancel button.
 *
 *  You can dismiss your controller here.
 *  Implementation of this method is optional, but expected.
 *  @param picker The controller object managing the image picker interface.
 */
- (void)imagePickerControllerDidCancel:(DDCameraImagePickerViewController *)picker;

/**
 *  Tells the delegate that the user tapped on Done button.
 *
 *  You can perform any task that you want to do after finish clicking all images(i.e. saving all the clicked images) in its implementation.
 *  Implementation of this method is optional, but expected.
 *  @param picker The controller object managing the image picker interface.
 */
- (void)imagePickerControllerDoneButtonTapped:(DDCameraImagePickerViewController *)picker;

/**
 *  Tells the delegate that the user tapped on Preview button.
 *
 *  You can push a new controller in which you can show all the clicked images and can dismiss this controller in its implementation.
 *  Implementation of this method is optional, but expected.
 *  If you will not implement this method then picker will be dismissed on tapping on Image.
 *  @param picker The controller object managing the image picker interface.
 */
- (void)imagePickerControllerPreviewButtonTapped:(DDCameraImagePickerViewController *)picker;

/**
 *  Tells the delegate that user has reached the threshold limit and can't click more photos.
 *
 *  @param picker The controller object managing the image picker interface.
 */

- (void)imagePickerControllerMaximumPhotoLimitReached:(DDCameraImagePickerViewController *)picker;

@end

@interface DDCameraImagePickerViewController : UIViewController

@property (nonatomic, weak) id <DDCameraImagePickerDelegate> delegate;

/**
 *  Title string for the TapForPhotoLabel.Default title is "Tap For Photo".
 */
@property (nonatomic,strong) NSString *tapForPhotoTitleString;

/**
 *  Title string for the Cancel Button. Default title is "Cancel".
 */
@property (nonatomic,strong) NSString *cancelButtonTitleString;

/**
 *  Title string for the Cancel Button. Default title is "Done".
 */
@property (nonatomic,strong) NSString *doneButtonTitleString;

/**
 *  Maximum no of photos that a user can click.
 */
@property (nonatomic,assign) NSInteger maxPhotoCount;

/**
 *  Yes When you want to show the count of the number of images clicked. Default is No.
 */
@property (nonatomic,assign) BOOL shouldShowCounter;

@end
