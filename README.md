# MultipleImagePickerFromCamera
MultipleImagePickerFromCamera is an alternate of UIImagePicker in which user can click multiple photos and can store at your own path.

In this project user can click multiple photos from the camera and can save all of them at your desire path. MultipleImagePickerFromCamera is using AVFoundation framework  and you can access front camera ,back camera and also the flashlight of your phone while clicking photos.

HOW TO USE :-

1. Make the object of DDCameraImagePickerViewController class and set some of its properties.


    DDCameraImagePickerViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DDCameraImagePickerViewController class])];
    viewController.tapForPhotoTitleString = @"Tap for Photo";
    viewController.doneButtonTitleString = @"Done";
    viewController.cancelButtonTitleString = @"Cancel";
    viewController.shouldShowCounter = YES;
    viewController.maxPhotoCount = 30;

2. Set the delegate for DDCameraImagePickerDelegate and implement its delegate methods.
