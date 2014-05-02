//
//  RecordViewController.m
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-03-17.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import "RecordViewController.h"
#import <TheAmazingAudioEngine/AERecorder.h>
#import <EZAudio/EZAudioPlotGL.h>

@interface RecordViewController ()

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;

@property (readonly, nonatomic) AEAudioController *audioController;
@property (strong, nonatomic) AEAudioFilePlayer *audioSourceFilePlayer;
@property (strong, nonatomic) AEAudioFilePlayer *audioOutputFilePlayer;
@property (strong, nonatomic) AERecorder *recorder;
@property (strong, nonatomic) AEFloatConverter *floatConverter;
@property (strong, nonatomic) AEBlockAudioReceiver *audioReceiver;

@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;

@property (nonatomic) float **floatBuffers;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recordButton.layer.cornerRadius = 8.0f;
    self.recordButton.layer.borderWidth = 1.0f;
    self.recordButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.uploadButton.hidden = YES;
    
    // Customize Waveform
    self.audioPlot.color = [UIColor colorWithRed:(252.0/255.0) green:(175.0/255.0) blue:(62.0/255.0) alpha:1.0];
    self.audioPlot.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1];
    self.audioPlot.plotType     = EZPlotTypeRolling;
    self.audioPlot.shouldFill   = YES;
    self.audioPlot.shouldMirror = YES;
    
    // Init float converter
    self.floatConverter = [[AEFloatConverter alloc] initWithSourceFormat:self.audioController.audioDescription];
    self.floatBuffers = (float**)malloc(sizeof(float*)*self.audioController.audioDescription.mChannelsPerFrame);
    assert(self.floatBuffers);
    for (int i = 0; i < self.audioController.audioDescription.mChannelsPerFrame; i++) {
        self.floatBuffers[i] = (float*)malloc([self getBufferFrameSize]);
        assert(self.floatBuffers[i]);
    }
    
    // Init audio receiver to draw waveform
    self.audioReceiver = [AEBlockAudioReceiver audioReceiverWithBlock:^(void *source,
                                                                        const AudioTimeStamp *time,
                                                                        UInt32 frames,
                                                                        AudioBufferList *audio) {
        dispatch_async(dispatch_get_main_queue(),^{
            if (AEFloatConverterToFloat(self.floatConverter, audio, self.floatBuffers, frames)) {
                [self.audioPlot updateBuffer:*self.floatBuffers withBufferSize:frames];
            }
        });
    }];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.audioOutputFilePlayer.channelIsPlaying) {
        [self stopAudio];
    }
    if (self.recorder) {
        [self endRecording];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Accessor

- (AEAudioController *)audioController {
    return ((AppDelegate *)([UIApplication sharedApplication].delegate)).audioController;
}


#pragma mark - Private Methods

- (UInt32)getBufferFrameSize {
    UInt32 bufferFrameSize;
    UInt32 propSize = sizeof(bufferFrameSize);
    [self checkResult:AudioUnitGetProperty(self.audioController.audioUnit,
#if TARGET_OS_IPHONE
                                              kAudioUnitProperty_MaximumFramesPerSlice,
#elif TARGET_OS_MAC
                                              kAudioDevicePropertyBufferFrameSize,
#endif
                                              kAudioUnitScope_Global,
                                              0,
                                              &bufferFrameSize,
                                              &propSize)
               operation:"Failed to get buffer frame size"];
    return bufferFrameSize;
}


- (void)checkResult:(OSStatus)result operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}


#pragma mark - Private Methods

- (IBAction)recordAction:(id)sender {
    if (!self.recorder) {
        [self startRecording];
    }
    else {
        [self endRecording];
    }
}


- (IBAction)uploadAction:(id)sender {
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL *trackURL = [NSURL fileURLWithPath:[documentsFolder stringByAppendingPathComponent:@"Recording.aiff"]];
    
    SCSharingViewControllerCompletionHandler handler = ^(NSDictionary *trackInfo, NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Uploaded track: %@", trackInfo);
        }
    };
    
    SCShareViewController *shareViewController = [SCShareViewController
                                                  shareViewControllerWithFileURL:trackURL
                                                  completionHandler:handler];
    [shareViewController setTitle:@"Test Recording"];
    [shareViewController setPrivate:YES];
    
    // TODO: Remove this workaround once SoundCloud fix it
    UIViewController *controller = [[UIViewController alloc] init];
    [controller addChildViewController:shareViewController];
    controller.view.backgroundColor = self.view.backgroundColor;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        shareViewController.view.frame = CGRectMake(shareViewController.view.frame.origin.x,
                                                    shareViewController.view.frame.origin.y + 20,
                                                    controller.view.frame.size.width,
                                                    controller.view.frame.size.height - 20);
    }
    else {
        shareViewController.view.frame = CGRectMake(shareViewController.view.frame.origin.x,
                                                    shareViewController.view.frame.origin.y,
                                                    controller.view.frame.size.width,
                                                    controller.view.frame.size.height);
    }
    [controller.view addSubview:shareViewController.view];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}


- (void)startRecording {
    NSLog(@"======== Start Recording ========");
    [self.recordButton setTitle:@"End Recording" forState:UIControlStateNormal];
    self.playButton.hidden = YES;
    [self.audioPlot clear];
    
    // Stop playing audio if starting a new recording
    if (self.audioOutputFilePlayer) {
        [self stopAudio];
    }
    if (!self.audioSourceFilePlayer) {
        // Read the file from within project
        NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"wav"];
        self.audioSourceFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:filePath audioController:self.audioController error:NULL];
        __weak RecordViewController *weakSelf = self;
        self.audioSourceFilePlayer.completionBlock = ^{
            [weakSelf endRecording];
        };
    }
    
    // Prepare file for recording
    self.recorder = [[AERecorder alloc] initWithAudioController:self.audioController];
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsFolder stringByAppendingPathComponent:@"Recording.aiff"];
    NSError *error = NULL;
    if (![_recorder beginRecordingToFileAtPath:filePath fileType:kAudioFileAIFFType error:&error]) {
        NSLog(@"Error: Failed to begin recording: %@", error);
        return;
    }
    
    [self.audioController addChannels:@[self.audioSourceFilePlayer]];
    [self.audioController addInputReceiver:self.recorder];
    [self.audioController addOutputReceiver:self.recorder];
    [self.audioController addInputReceiver:self.audioReceiver];
    [self.audioController addOutputReceiver:self.audioReceiver];
}


- (void)endRecording {
    NSLog(@"======== End Recording ========");
    self.playButton.hidden = NO;
    [self.recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    
    [self.audioController removeChannels:@[self.audioSourceFilePlayer]];
    [self.audioController removeInputReceiver:self.recorder];
    [self.audioController removeOutputReceiver:self.recorder];
    [self.audioController removeInputReceiver:self.audioReceiver];
    [self.audioController removeOutputReceiver:self.audioReceiver];
    [self.recorder finishRecording];
    
    self.uploadButton.hidden = NO;
    self.recorder = nil;
    self.audioSourceFilePlayer = nil;
}


- (IBAction)playAction:(id)sender {
    if (self.audioOutputFilePlayer.channelIsPlaying) {
        [self stopAudio];
    }
    else {
        [self playAudio];
    }
}


- (void)playAudio {
    NSLog(@"======== Start Playing ========");
    [self.playButton setImage:[UIImage imageNamed:@"stop_icon"] forState:UIControlStateNormal];
    
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL *filePath = [NSURL fileURLWithPath:[documentsFolder stringByAppendingPathComponent:@"Recording.aiff"]];
    self.audioOutputFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:filePath audioController:self.audioController error:NULL];
    __weak RecordViewController *weakSelf = self;
    self.audioOutputFilePlayer.completionBlock = ^{
        [weakSelf stopAudio];
    };
    [self.audioController addChannels:@[self.audioOutputFilePlayer]];
}


- (void)stopAudio {
    NSLog(@"======== Stop Playing ========");
    [self.playButton setImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
    
    [self.audioController removeChannels:@[self.audioOutputFilePlayer]];
    self.audioOutputFilePlayer.currentTime = 0.0;
    self.audioOutputFilePlayer = nil;
}

@end
