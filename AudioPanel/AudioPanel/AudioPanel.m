//
//  MKInfoPanel.m
//  HorizontalMenu
//
//  Created by Mugunth on 25/04/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/8e on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

//  Created by Dmitry Shmidt on 5/26/12.
#import "AudioPanel.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AudioToolbox/AudioToolbox.h>

#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>
// Private Methods
// this should be added before implementation block 

@interface AudioPanel (PrivateMethods)
+ (AudioPanel*) panel;
@end


@implementation DimmedView

- (id)initWithParent:(UIView*) aParentView onTappedSelector:(SEL) tappedSel
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
        parentView = aParentView;
        onTapped = tappedSel;
        self.backgroundColor = [UIColor darkGrayColor];//RGB(15, 15, 25);RGB(0, 0, 30);
        self.alpha = 0.0;
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [parentView performSelector:onTapped];

}
@end

@implementation AudioPanel{
    NSTimer *timer;    
    
}
@synthesize activityIndicatorView;
@synthesize closeBlock = _closeBlock;

@synthesize recordButton;
@synthesize musicLibraryButton;
@synthesize playButton;
@synthesize timeLabel;
@synthesize slider;
@synthesize progress;
@synthesize dimmedView = _dimmedView;
@synthesize soundFileURL;
@synthesize viewController;
@synthesize deleteButton;
@synthesize soundPlayer;
@synthesize soundRecorder;
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

+(AudioPanel*) panel
{
    AudioPanel *panel =  (AudioPanel*) [[[UINib nibWithNibName:@"AudioPanel" bundle:nil] 
                                           instantiateWithOwner:self options:nil] objectAtIndex:0];


//    panel.backgroundImageView.image =  [UIImage imageNamed:@"carbon_fibre_big"];
    panel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
//    panel.backgroundGradient.image = [[UIImage imageNamed:@"TopBar"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];

    CATransition *transition = [CATransition animation];
	transition.duration = kAnimationDuration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromTop;
	[panel.layer addAnimation:transition forKey:nil];
    [panel.activityIndicatorView stopAnimating];
    return panel;
}
+(void) showInViewController:(UIViewController *)viewController fileURL:(NSURL *)fileURL onClose:(CloseBlock) completionBlock{
    AudioPanel *panel = [AudioPanel panel];
        panel.frame = CGRectMake((viewController.view.frame.size.width - panel.frame.size.width)/2, viewController.view.frame.size.height - panel.frame.size.height, panel.frame.size.width, panel.frame.size.height);
    panel.closeBlock = completionBlock;
    panel.soundFileURL = fileURL;
    panel.viewController = viewController;
    //    panel.titleLabel.text = title;
    //    [panel.entryField becomeFirstResponder];
    DimmedView *dimmedView = [[DimmedView alloc] initWithParent:panel onTappedSelector:@selector(cancelTapped:)];
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelTapped:)];
    //    [dimview addGestureRecognizer:tap];
    panel.dimmedView = dimmedView;
    //    panel.dimView = [[DimView alloc] initWithParent:panel onTappedSelector:@selector(cancelTapped:)];
    CATransition *transition = [CATransition animation];
	transition.duration = kAnimationDuration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionFade;
	[panel.dimmedView.layer addAnimation:transition forKey:nil];
    panel.dimmedView.alpha = 0.1;
    [viewController.view addSubview:panel.dimmedView];
    [UIView animateWithDuration:0.4 animations:^{
        panel.dimmedView.alpha = 0.8;
    }];
    [viewController.view addSubview:panel];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //Turn on speaker
    audioSession.delegate = self;
    NSError *error = nil;
    [audioSession setActive: YES error: &error];
    NSLog([error localizedDescription]);
    
    if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
        panel.soundPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
        panel.soundPlayer.delegate = panel;
        panel.timeLabel.text = [NSString stringWithFormat:@"%@", [panel formatTime:panel.soundPlayer.duration]];
        panel.slider.value = 0.0f;
        panel.slider.alpha = 1;
        panel.timeLabel.alpha = 1;
//        [panel.soundPlayer prepareToPlay];
        NSLog(@"Playing temp sound");
    }else {
        NSLog(@"No audiofile");
        panel.recordButton.enabled = YES;
        panel.playButton.enabled = NO;
        panel.deleteButton.enabled = NO;
        panel.slider.alpha = 0;
        panel.timeLabel.alpha = 0;
    } 
    //    recording = NO;
}

- (IBAction)deleteSoundFile:(id)sender {
    
    UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil)  otherButtonTitles:nil, nil];
    as.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [as showInView:self.viewController.view];
    

//    slider.hidden = YES;
//    timeLabel.text = @" ";
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm removeItemAtURL:soundFileURL error:nil];
        deleteButton.enabled = NO;
        playButton.enabled = NO;
        recordButton.enabled = YES;
        musicLibraryButton.enabled = YES;
        [UIView animateWithDuration:0.4 animations:^{
            slider.alpha = 0;
            timeLabel.alpha = 0;
            
        }];
        [self close:nil];
    }
}
- (IBAction)recordSoundFile {
    recordButton.selected = YES;
    playButton.enabled = NO;
    musicLibraryButton.enabled = NO;

    [UIView animateWithDuration:0.5 animations:^{
        slider.alpha = 0;
        timeLabel.alpha = 1;
        progress.alpha = 1;
    }];
    
    if (self.soundRecorder.recording) {        
        [self.soundRecorder stop];
        self.soundRecorder = nil;
        [timer invalidate];
        timer = nil;
        recordButton.selected = NO;
        playButton.enabled = YES;
        NSError *error;
        [[AVAudioSession sharedInstance] setActive: NO error: &error];
        NSLog([error localizedDescription]);
    }else {
        if (!self.soundRecorder) {
            NSError *errorAudioSession;
            [[AVAudioSession sharedInstance]
             setCategory: AVAudioSessionCategoryPlayAndRecord
             error: &errorAudioSession];
            NSLog([errorAudioSession description]);
            
            NSDictionary *recordSettings =
            [[NSDictionary alloc] initWithObjectsAndKeys:
             //     [NSNumber numberWithFloat: 32000.0], AVSampleRateKey,
             [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
             [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
             //     [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
             [NSNumber numberWithInt: AVAudioQualityMedium],
             AVEncoderAudioQualityKey,
             nil];
            
            NSError *error;
            AVAudioRecorder *newRecorder =
            [[AVAudioRecorder alloc] initWithURL: soundFileURL
                                        settings: recordSettings
                                           error: &error];
            NSLog([error description]);
            self.soundRecorder = newRecorder;            
            self.soundRecorder.delegate = self;
            

        }
        [self.soundRecorder stop];
        [self.soundRecorder prepareToRecord];
        self.soundRecorder.meteringEnabled = YES;
        [self.soundRecorder record];
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateRecordStatus) userInfo:nil repeats:YES];
    } 

        //    [hud hide];
    //    hud = nil;
}

- (IBAction)importSoundFile {
    NSLog(@"%s",__PRETTY_FUNCTION__);
   
    [UIView animateWithDuration:0.5 animations:^{
        slider.alpha = 0;
        timeLabel.alpha = 0;
    }];
    musicLibraryButton.enabled = NO;
    recordButton.enabled = NO;
    deleteButton.enabled = NO;
    playButton.enabled = NO;
    MPMediaPickerController *pickerController =	[[MPMediaPickerController alloc]
												 initWithMediaTypes: MPMediaTypeMusic];
	pickerController.prompt = NSLocalizedString(@"Choose song to import", nil) ;
	pickerController.allowsPickingMultipleItems = NO;
	pickerController.delegate = self;
	[self.viewController presentModalViewController:pickerController animated:YES];
}

- (IBAction)playSoundFile {
    playButton.selected = YES;
    recordButton.enabled = NO;
    musicLibraryButton.enabled = NO;
    
    if (self.soundPlayer.playing) {
        NSLog(@"pausing player");
        [timer invalidate];
        timer = nil;
        [self.soundPlayer pause];
        playButton.selected = NO;
        recordButton.enabled = YES;
        musicLibraryButton.enabled = YES;
    }else {
        if (!self.soundPlayer) {
            NSError *error;
            if ([self.soundFileURL checkResourceIsReachableAndReturnError:&error]) {
                NSLog(@"initializing player");
                self.soundPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:self.soundFileURL error:&error];
                NSLog([error localizedDescription]);
                self.soundPlayer.delegate = self;
                UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
                NSLog(@"Playing temp sound");
                [self.soundPlayer prepareToPlay];
                [self.soundPlayer play];
                timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updatePlayStatus) userInfo:nil repeats:YES];
            }else {
                NSLog(@"No audiofile");
                playButton.selected = NO;
            }
            
        }else {
            NSLog(@"play");
            [UIView animateWithDuration:0.5 animations:^{
                slider.alpha = 1;
                progress.alpha = 0;
            }];
            [self.soundPlayer prepareToPlay];
            [self.soundPlayer play];
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updatePlayStatus) userInfo:nil repeats:YES];
        }
    }
}

- (IBAction)close:(id)sender {
    if (self.soundPlayer) {
        self.soundPlayer.delegate = nil;
        self.soundPlayer = nil;
    }
    if (self.soundRecorder) {
        self.soundRecorder.delegate = nil;
        self.soundRecorder = nil;
    }
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [self performSelectorOnMainThread:@selector(hidePanel) withObject:nil waitUntilDone:YES];    
    self.closeBlock(self.soundFileURL);
}

-(void) cancelTapped:(id) sender
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self performSelectorOnMainThread:@selector(hidePanel) withObject:nil waitUntilDone:YES];    
}

-(void) hidePanel
{
//    [self.entryField resignFirstResponder];
    CATransition *transition = [CATransition animation];
	transition.duration = kAnimationDuration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromBottom;
	[self.layer addAnimation:transition forKey:nil];
    self.frame = CGRectMake(0, -self.frame.size.height, 320, self.frame.size.height); 
    NSLog(@"%s",__PRETTY_FUNCTION__);
    transition = [CATransition animation];
	transition.duration = kAnimationDuration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionFade;
	self.dimmedView.alpha = 0.0;
	[self.dimmedView.layer addAnimation:transition forKey:nil];
    
    [self.dimmedView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.40];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.45];
}

#pragma mark - Sound
// Update playback point during scrubs
- (IBAction) scrub: (id) sender
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

	soundPlayer.currentTime = slider.value * soundPlayer.duration;

	timeLabel.text = [NSString stringWithFormat:@"%@", [self formatTime:soundPlayer.currentTime]];
}

- (NSString *) formatTime: (int) num
{
	int secs = num % 60;
	int min = num / 60;
	
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}
- (void) updateRecordStatus
{
    [self.soundRecorder updateMeters];
    double avgPowerForChannel = pow(10, (0.05 * [self.soundRecorder averagePowerForChannel:0]));
    //    [micSprite receiveInput:avgPowerForChannel];
    
    NSLog(@"Avg. Power: %f", [self.soundRecorder averagePowerForChannel:0]);
	progress.progress = avgPowerForChannel;
    timeLabel.text = [self formatTime:self.soundRecorder.currentTime];
}
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.soundRecorder.delegate = nil;
    self.soundRecorder = nil;
    [timer invalidate];
    timer = nil;
    recordButton.selected = NO;

    musicLibraryButton.enabled = YES;
    if (flag) {
        NSLog(@"Recorded!");
        deleteButton.enabled = YES;
        slider.value = 0.0f;
        [UIView animateWithDuration:0.5 animations:^{
            slider.alpha = 1;
            progress.alpha = 0;
        }];

        playButton.enabled = YES;
    }    

}
#pragma mark -
-(void)doVolumeFade
{  
    if (soundPlayer.volume > 0.1) {
        soundPlayer.volume = soundPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];           
    } else {
        // Stop and get the sound ready for playing again
        [soundPlayer stop];
        soundPlayer.currentTime = 0;
        [soundPlayer prepareToPlay];
        soundPlayer.volume = 1.0;
        soundPlayer = nil;
    }
}

- (void) updatePlayStatus
{
    // Retrieve current values
    //	[player updateMeters];
    
    // Show those values on the two meters
    //	float avg = -1.0f * [player averagePowerForChannel:0];
    //	float peak = -1.0f * [player peakPowerForChannel:0];
    //	meter1.progress = (XMAX - avg) / XMAX;
    //	meter2.progress = (XMAX - peak) / XMAX;
    
    // And on the scrubber
//    if (!isnan(soundPlayer.currentTime / soundPlayer.duration)) {
        slider.value = (soundPlayer.currentTime / soundPlayer.duration);
//    }else {
//        slider.value = 1;
//        [timer invalidate];
//        timer = nil;
//        playButton.selected = NO;
//        recordButton.enabled = YES;
//        musicLibraryButton.enabled = YES;
//        soundPlayer = nil;
//        soundPlayer.delegate = nil;
//    }
    
    NSLog(@"%f", (soundPlayer.currentTime / soundPlayer.duration));
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [self formatTime:(soundPlayer.duration - soundPlayer.currentTime)]];
    //    self.timeLabel.text = [NSString stringWithFormat:@"%@ of %@", [self formatTime:player.currentTime], [self formatTime:player.duration]];
    // Display the current playback progress in minutes and seconds
    //	self.title = [NSString stringWithFormat:@"%@ of %@", [self formatTime:player.currentTime], [self formatTime:player.duration]];
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

    if (flag) {
        NSLog(@"Played!");
        slider.value = 1.0;
        [UIView animateWithDuration:0.5 animations:^{
            slider.value = 0.0;
            [self updatePlayStatus];
        }];
    }
    [timer invalidate];
    timer = nil;
    playButton.selected = NO;
    recordButton.enabled = YES;
    musicLibraryButton.enabled = YES;
    self.soundPlayer = nil;
    self.soundPlayer.delegate = nil;
}
#pragma mark -

#pragma mark - Import sound

-(void) createM4AFromMediaItem:(MPMediaItem *) song{
	// set up an AVAssetReader to read from the iPod Library
	NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
	AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
	NSError *assetError = nil;
	AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
															   error:&assetError];
	if (assetError) {
		NSLog (@"error: %@", assetError);
		return;
	}
	
	AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput 
											  assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil];
	if (! [assetReader canAddOutput: assetReaderOutput]) {
		NSLog (@"can't add reader output...");
		return;
	}
	[assetReader addOutput: assetReaderOutput];
    //	
    //	NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //	NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    //	NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:EXPORT_NAME];
    //	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
    //		[[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    //	}
    //	NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    
	AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:soundFileURL
														  fileType:AVFileTypeAppleM4A
															 error:&assetError];
	if (assetError) {
		NSLog (@"error: %@", assetError);
		return;
	}
    
    AudioChannelLayout channelLayout;
	memset(&channelLayout, 0, sizeof(AudioChannelLayout));
	channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *outputSettings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     //         [NSNumber numberWithFloat: 32000.0], AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
     [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
     [NSNumber numberWithInt:128000], AVEncoderBitRateKey,
     [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
     [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
     //         [NSNumber numberWithInt: AVAudioQualityLow],
     //         AVEncoderAudioQualityKey,
     nil];
    
	AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
																			  outputSettings:outputSettings];
	if ([assetWriter canAddInput:assetWriterInput]) {
		[assetWriter addInput:assetWriterInput];
	} else {
		NSLog (@"can't add asset writer input...");
		return;
	}
	
	assetWriterInput.expectsMediaDataInRealTime = NO;
    
	[assetWriter startWriting];
	[assetReader startReading];
    
	AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
	CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
	[assetWriter startSessionAtSourceTime: startTime];
	
    //	__block UInt64 convertedByteCount = 0;
	
	dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
	[assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue 
											usingBlock: ^ 
	 {
		 // NSLog (@"top of block");
		 while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 //                 //				NSLog (@"appended a buffer (%d bytes)", 
                 //                 //					   CMSampleBufferGetTotalSampleSize (nextBuffer));
                 //                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 //                 // oops, no
                 //                 // sizeLabel.text = [NSString stringWithFormat: @"%ld bytes converted", convertedByteCount];
                 //                 
                 //                 NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];
                 //                 [self performSelectorOnMainThread:@selector(updateSizeLabel:)
                 //                                        withObject:convertedByteCountNumber
                 //                                     waitUntilDone:NO];
             } else {
                 // done!
                 
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWriting];
                 [assetReader cancelReading];
                 [self.activityIndicatorView stopAnimating];
//                 [ActivityAlert dismiss];
                 NSLog(@"Finished importing");
                 playButton.enabled = YES;
                 deleteButton.enabled = YES;
                 recordButton.enabled = YES;
                 musicLibraryButton.enabled = YES;
                 if ([soundFileURL checkResourceIsReachableAndReturnError:nil]) {
                     self.soundPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:soundFileURL error:nil];
                     self.soundPlayer.delegate = self;
                     self.timeLabel.text = [NSString stringWithFormat:@"%@", [self formatTime:self.soundPlayer.duration]];
                     self.slider.value = 0.0f;
                     [UIView animateWithDuration:0.5 animations:^{
                         slider.alpha = 1;
                         timeLabel.alpha = 1;
                     }];
                     [self.soundPlayer prepareToPlay];
                     NSLog(@"Prepare for imported sound");
                 }
                 //                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                 //                                                       attributesOfItemAtPath:exportPath
                 //                                                       error:nil];
                 //                 NSLog (@"done. file size is %ld",
                 //					    [outputFileAttributes fileSize]);
                 //                 NSNumber *doneFileSize = [NSNumber numberWithLong:[outputFileAttributes fileSize]];
                 //                 [self performSelectorOnMainThread:@selector(updateCompletedSizeLabel:)
                 //                                        withObject:doneFileSize
                 //                                     waitUntilDone:NO];
                 break;
             }
         }
         
	 }];
    
}
#pragma mark MPMediaPickerControllerDelegate
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[self.viewController dismissModalViewControllerAnimated:YES];
	if ([mediaItemCollection count] < 1) {
		return;
	}
//    [ActivityAlert presentWithText:@"Importing\n Please wait..."];
    [self.activityIndicatorView startAnimating];
	MPMediaItem *song = [[mediaItemCollection items] objectAtIndex:0];
    NSLog(@"importing song");
    
    [self createM4AFromMediaItem:song];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self.viewController dismissModalViewControllerAnimated:YES];
    musicLibraryButton.enabled = YES;
    playButton.enabled = YES;
    deleteButton.enabled = YES;
    recordButton.enabled = YES;
}

@end


