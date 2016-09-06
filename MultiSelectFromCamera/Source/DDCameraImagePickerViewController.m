//
//  CustomCameraPickerViewController.m
//  MultiSelectFromCamera
//
//  Created by Deepak Dogra on 29/08/16.
//  Copyright © 2016 Deepak Dogra. All rights reserved.
//

#import "DDCameraImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface DDCameraImagePickerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *flashLightButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *tapForPhotoLabel;
@property (weak, nonatomic) IBOutlet UIView *cameraBackgroundView;

@property (nonatomic,assign) NSInteger clickedImagesCount;
@property (nonatomic,assign) BOOL isFlashLightOn;

@end

@implementation DDCameraImagePickerViewController

AVCaptureSession *session;
AVCaptureStillImageOutput *stillImageOutput;

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

///////////////////////////////////////
#pragma mark View lifecycle methods
///////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clickedImagesCount = 0;
    [self.actionButton setTitle:self.cancelButtonTitleString ? self.cancelButtonTitleString : @"Cancel" forState:UIControlStateNormal];
    self.tapForPhotoLabel.text = self.tapForPhotoTitleString ? self.tapForPhotoTitleString : @"Tap for Photo";
    self.isFlashLightOn = YES;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addTapGestureRecognizerForImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.view.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
    [session startRunning];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

///////////////////////////////////////
#pragma mark Button Action methods
///////////////////////////////////////

- (IBAction)takePhotoButtonTapped:(id)sender {
    
    [self configureFlash:self.isFlashLightOn];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                
                // We want to show the clicked image in portrait mode only irrespective of the device orientation.For this we need to change the imageOrientation property of the UIImage.To achieve this we are setting the videoOrientation property of our videoConnection which is responsible for capturing image.
                
                AVCaptureVideoOrientation newOrientation;
                switch ([[UIDevice currentDevice] orientation]) {
                    case UIDeviceOrientationPortrait:
                        newOrientation = AVCaptureVideoOrientationPortrait;
                        break;
                    case UIDeviceOrientationPortraitUpsideDown:
                        newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                        break;
                    case UIDeviceOrientationLandscapeLeft:
                        newOrientation = AVCaptureVideoOrientationLandscapeRight;
                        break;
                    case UIDeviceOrientationLandscapeRight:
                        newOrientation = AVCaptureVideoOrientationLandscapeLeft;
                        break;
                    default:
                        newOrientation = AVCaptureVideoOrientationPortrait;
                }
                [videoConnection setVideoOrientation: newOrientation];
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    __weak typeof (self) weakSelf = self;
    
    if (self.clickedImagesCount >= self.maxPhotoCount  ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerControllerMaximumPhotoLimitReached:)]) {
            [self.delegate imagePickerControllerMaximumPhotoLimitReached:self];
        }
    }else {
        
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [UIImage imageWithData:imageData];
                
                // Changing orientation of the clicked image here.
                UIImage *rotatedImage = [self scaleAndRotateClickedImage:image];
                
                weakSelf.clickedImagesCount += 1;
                if ( weakSelf.clickedImagesCount == 1) { // we will set the done button title once only.
                    [weakSelf.actionButton setTitle:self.doneButtonTitleString ? self.doneButtonTitleString : @"Done" forState:UIControlStateNormal];
                    if (weakSelf.shouldShowCounter) {
                        [weakSelf.takePhotoButton setTitle:[NSString stringWithFormat:@"%ld",(long)weakSelf.clickedImagesCount] forState:UIControlStateNormal];
                    }
                    
                }else if(weakSelf.shouldShowCounter) {
                    [weakSelf.takePhotoButton setTitle:[NSString stringWithFormat:@"%ld",(long)weakSelf.clickedImagesCount] forState:UIControlStateNormal];
                }
                
                weakSelf.imageView.image = rotatedImage;
                
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imagePickerController:
                                                                                         didFinishPickingImage:)]) {
                    [weakSelf.delegate imagePickerController:weakSelf didFinishPickingImage:image];
                }
            }
        }];
    }
}

- (IBAction)actionButtonTapped:(id)sender {
    if (self.clickedImagesCount == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
            [self.delegate imagePickerControllerDidCancel:self];
        }else {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerControllerDoneButtonTapped:)]) {
            [self.delegate imagePickerControllerDoneButtonTapped:self];
        }else {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

- (IBAction)toggleFlashLight:(UIButton *)sender {
    self.isFlashLightOn = !self.isFlashLightOn;
    sender.selected = !sender.selected;
}


- (IBAction)changeCameraFacingButtonTapped:(id)sender {
    //Change camera source
    if(session){
        [self flipCamera];
    }
}

- (void)configureFlash:(BOOL)flashMode {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (!self.isFlashLightOn) {
                [device setFlashMode:AVCaptureFlashModeOn];
            }else {
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

-(void)flipCamera {
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithFrame:self.cameraBackgroundView.bounds];
    blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [self.cameraBackgroundView addSubview:blurView];

    __weak typeof (self) weakSelf = self;

    [UIView transitionWithView:self.cameraBackgroundView duration:0.8 options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil completion:^(BOOL finished) {
    
        AVCaptureInput* currentCameraInput = [session.inputs objectAtIndex:0];
        [session removeInput:currentCameraInput];
        
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
            newCamera = [weakSelf cameraWithPosition:AVCaptureDevicePositionFront];
            self.isFlashLightOn = NO;
            self.flashLightButton.hidden = YES;
        }else {
            newCamera = [weakSelf cameraWithPosition:AVCaptureDevicePositionBack];
            self.flashLightButton.hidden = NO;
        }
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!deviceInput || err) {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }else {
            [session addInput:deviceInput];
        }
        
        //Commit all the configuration changes at once
        [session commitConfiguration];
        
        [blurView removeFromSuperview];
    }];
}

///////////////////////////////////////
#pragma mark Image Modification Method
///////////////////////////////////////

- (UIImage*) scaleAndRotateClickedImage:(UIImage*)image
{
    int kMaxResolution = 320; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width / height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
            
        case UIImageOrientationUp: // EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: // EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: // EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: // EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: // EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: // EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: // EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: // EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage* imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

///////////////////////////////////////
#pragma mark Adding Gesture Recognizer
///////////////////////////////////////

- (void) addTapGestureRecognizerForImageView {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)tappedImage:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.delegate && self.imageView.image != nil && [self.delegate respondsToSelector:@selector(imagePickerControllerPreviewButtonTapped:)]) {
        [self.delegate imagePickerControllerPreviewButtonTapped:self];
    }else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

@end
