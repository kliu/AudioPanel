//
//  MKEntryPanel.h
//  HorizontalMenu
//
//  Created by Mugunth on 25/04/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

//  Created by Dmitry Shmidt on 5/26/12.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef void (^CloseBlock)(NSURL *fileURL);

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kAnimationDuration 0.35

@interface DimmedView : UIView {
    
    SEL onTapped;
    UIView *parentView;
}

- (id)initWithParent:(UIView*) aParentView onTappedSelector:(SEL) tappedSel;
@end

@interface AudioPanel : UIView <AVAudioPlayerDelegate, AVAudioRecorderDelegate, AVAudioSessionDelegate, UIActionSheetDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, copy) CloseBlock closeBlock;
@property (nonatomic) DimmedView *dimmedView;
@property (nonatomic, strong) NSURL *soundFileURL;
@property (nonatomic, strong) AVAudioPlayer *soundPlayer;
@property (nonatomic, strong) AVAudioRecorder *soundRecorder;
@property (nonatomic, strong) UIViewController *viewController;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *recordButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *musicLibraryButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *playButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *timeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *slider;
@property (unsafe_unretained, nonatomic) IBOutlet UIProgressView *progress;

- (IBAction)deleteSoundFile:(id)sender;
- (IBAction)recordSoundFile;
- (IBAction)importSoundFile;
- (IBAction)playSoundFile;
- (IBAction)close:(id)sender;
- (IBAction) scrub: (id) sender;
+(void) showInViewController:(UIViewController *)viewController fileURL:(NSURL *) fileURL onClose:(CloseBlock) completionBlock;
@end
