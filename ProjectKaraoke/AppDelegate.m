//
//  AppDelegate.m
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-03-17.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import "AppDelegate.h"
#import "UserManager.h"

@implementation AppDelegate

- (AEAudioController *)audioController {
    if (!_audioController) {
        _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES useVoiceProcessing:YES];
        NSError *error = NULL;
        BOOL result = [_audioController start:&error];
        if (!result) {
            NSLog(@"Error: Audio Controller failed to start.");
        }
    }
    return _audioController;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![UserManager isLoggedIn]) {
        UIStoryboard *storyboard;
        if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        }
        else {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        }
        
        UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"LandingNavigationController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = navigationController;
        [self.window makeKeyAndVisible];
    }
    
	[APHLogger startNewSessionWithApplicationKey:APPHANCE_APP_KEY];
    NSSetUncaughtExceptionHandler(&APHUncaughtExceptionHandler);
    
    [SCSoundCloud  setClientID:SOUNDCLOUD_CLIENT_ID
                        secret:SOUNDCLOUD_CLIENT_SECRET
                   redirectURL:[NSURL URLWithString:@"ProjectKaraoke://oauth"]];
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    if ([sourceApplication isEqualToString:@"com.apple.mobilesafari"]) {
        if ([url.scheme hasPrefix:@"fb"]) {
            [FBSession.activeSession setStateChangeHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                [self sessionStateChanged:session state:state error:error];
            }];
            return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        }
        
        // TODO: Update when handling SoundCloud authentication
        NSLog(@"URL scheme:%@", [url scheme]);
        NSLog(@"URL query: %@", [url query]);
        
        return YES;
    }
    
    return NO;
}


- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    if (!error && state == FBSessionStateOpen) {
        NSLog(@"Facebook session opened");
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        NSLog(@"Facebook session closed");
    }
    
    // Handle errors
    if (error) {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
            alertTitle = @"Something went wrong with Facebook session";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showAlertMessage:alertText withTitle:alertTitle];
        }
        else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Facebook session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showAlertMessage:alertText withTitle:alertTitle];
            }
            else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showAlertMessage:alertText withTitle:alertTitle];
            }
        }
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}


- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


@end
