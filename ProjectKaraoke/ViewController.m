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

@property (strong, nonatomic) IBOutlet UIButton *startRecordingButton;

@property (readonly, nonatomic) AEAudioController *audioController;
@property (strong, nonatomic) AERecorder *recorder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationController.navigationBar.hidden = YES;
    
    self.startRecordingButton.layer.cornerRadius = 8.0f;
    self.startRecordingButton.layer.borderWidth = 1.0f;
    self.startRecordingButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
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

- (IBAction)startRecording:(id)sender {
    if (!self.recorder) {
//        NSBundle *mainBundle = [NSBundle mainBundle];
//        NSString *filePath = [mainBundle pathForResource: @"test" ofType: @"wav"];
        NSLog(@"Start Recording");
        self.recorder = [[AERecorder alloc] initWithAudioController:self.audioController];
        NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsFolder stringByAppendingPathComponent:@"Recording.aiff"];
        NSError *error = NULL;
        if (![_recorder beginRecordingToFileAtPath:filePath fileType:kAudioFileAIFFType error:&error]) {
            NSLog(@"Error: Failed to begin recording: %@", error);
            return;
        }
        
        [self.audioController addInputReceiver:self.recorder];
        [self.audioController addOutputReceiver:self.recorder];
        
        [self.startRecordingButton setTitle:@"End Recording" forState:UIControlStateNormal];
    }
    else {
        NSLog(@"End Recording");
        [self endRecording];
        
        [self.startRecordingButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    }
}


- (void)endRecording {
    [self.audioController removeInputReceiver:self.recorder];
    [self.audioController removeOutputReceiver:self.recorder];
    [self.recorder finishRecording];
    self.recorder = nil;
}


@end
