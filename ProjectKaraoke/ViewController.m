//
//  ViewController.m
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-03-17.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import "ViewController.h"
#import "AERecorder.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (readonly, nonatomic) AEAudioController *audioController;
@property (strong, nonatomic) AEAudioFilePlayer* audioSourceFilePlayer;
@property (strong, nonatomic) AEAudioFilePlayer* audioOutputFilePlayer;
@property (strong, nonatomic) AERecorder *recorder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationController.navigationBar.hidden = YES;
    
    self.recordButton.layer.cornerRadius = 8.0f;
    self.recordButton.layer.borderWidth = 1.0f;
    self.recordButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    // Read the file from within project
    NSURL *filePath = [[NSBundle mainBundle] URLForResource: @"test" withExtension: @"wav"];
    self.audioSourceFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:filePath audioController:self.audioController error:NULL];
    __weak ViewController *weakSelf = self;
    self.audioOutputFilePlayer.completionBlock = ^{
        [weakSelf endRecording];
    };
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

- (IBAction)recordingAction:(id)sender {
    if (!self.recorder) {
        NSLog(@"======== Start Recording ========");
        [self startRecording];
    }
    else {
        NSLog(@"======== End Recording ========");
        [self endRecording];
    }
}


- (void)startRecording {
    self.playButton.hidden = YES;
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
    
    [self.recordButton setTitle:@"End Recording" forState:UIControlStateNormal];
}


- (void)endRecording {
    [self.audioController removeChannels:@[self.audioSourceFilePlayer]];
    self.audioSourceFilePlayer.currentTime = 0.0;
    
    [self.audioController removeInputReceiver:self.recorder];
    [self.audioController removeOutputReceiver:self.recorder];
    [self.recorder finishRecording];
    
    self.playButton.hidden = NO;
    self.recorder = nil;
    
    [self.recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
}


- (IBAction)playAction:(id)sender {
    if (self.audioOutputFilePlayer.channelIsPlaying) {
        NSLog(@"======== Stop Playing ========");
        [self stopAudio];
    }
    else {
        NSLog(@"======== Start Playing ========");
        [self playAudio];
    }
}


- (void)playAudio {
    [self.playButton setImage:[UIImage imageNamed:@"stop_icon"] forState:UIControlStateNormal];
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL *filePath = [NSURL URLWithString:[documentsFolder stringByAppendingPathComponent:@"Recording.aiff"]];
    self.audioOutputFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:filePath audioController:self.audioController error:NULL];
    __weak ViewController *weakSelf = self;
    self.audioOutputFilePlayer.completionBlock = ^{
        [weakSelf stopAudio];
    };
    [self.audioController addChannels:@[self.audioOutputFilePlayer]];
}


- (void)stopAudio {
    [self.playButton setImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
    [self.audioController removeChannels:@[self.audioOutputFilePlayer]];
    self.audioOutputFilePlayer.currentTime = 0.0;
}

@end
