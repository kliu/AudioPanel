//
//  ViewController.m
//  AudioPanel
//
//  Created by Dmitry Shmidt on 5/26/12.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)showAudioPanel {
    NSURL *soundFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: @"temporary.m4a"]];
    [AudioPanel showInViewController:self fileURL:soundFileURL onClose:^(NSURL *fileURL) {
        if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
            //Save file
        }else {
            //File was deleted
        }
    }];
}
@end
