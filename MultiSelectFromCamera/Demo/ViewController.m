//
//  ViewController.m
//  MultiSelectFromCamera
//
//  Created by Deepak Dogra on 29/08/16.
//  Copyright © 2016 Deepak Dogra. All rights reserved.
//

#import "ViewController.h"
#import "DDCameraImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

- (IBAction)cameraButtonTapped:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButtonTapped:(id)sender {
    
    DDCameraImagePickerViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DDCameraImagePickerViewController class])];
    viewController.tapForPhotoTitleString = @"Tap for Photo";
    viewController.doneButtonTitleString = @"Done";
    viewController.cancelButtonTitleString = @"Cancel";
    viewController.shouldShowCounter = YES;
    viewController.maxPhotoCount = 30;
    [self.navigationController presentViewController:viewController animated:YES completion:^{
        
    }];
}
@end
