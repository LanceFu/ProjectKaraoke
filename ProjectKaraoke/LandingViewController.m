//
//  LandingViewController.m
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-04-22.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import "LandingViewController.h"

@interface LandingViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *facebookAccounts;

@end

@implementation LandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (IBAction)loginWithFacebookAction:(id)sender {
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
                                  }];
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            [SVProgressHUD showWithStatus:@"Authenticating"];
            [[FBRequest requestForGraphPath:@"me/accounts"] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
                [SVProgressHUD dismiss];
                NSArray<FBGraphObject> *accounts = [result objectForKey:@"data"];
                
                [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                    [SVProgressHUD dismiss];
                    
                    if ([accounts count] > 1) {
                        self.facebookAccounts = accounts;
                        
                        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose a Facebook Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                        [sheet addButtonWithTitle:[NSString stringWithFormat:@"You (%@)", [user objectForKey:@"name"]]];
                        for (NSDictionary *acct in accounts) {
                            [sheet addButtonWithTitle:[acct objectForKey:@"name"]];
                        }
                        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
                        sheet.tag = 0;
                        [sheet showInView:self.view];
                    }
                    else {
                        [self receiveGraphConnection:connection userDictionary:user token:[FBSession.activeSession.accessTokenData accessToken] error:error];
                    }
                }];
            }];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            break;
        }
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)receiveGraphConnection:(FBRequestConnection*)connection userDictionary:(NSDictionary<FBGraphUser>*)user token:(NSString *)token error:(NSError*)error {
    // Authenticate with our server and update view here
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if (buttonIndex == 0){
                [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                    [SVProgressHUD dismiss];
                    [self receiveGraphConnection:connection userDictionary:user token:[FBSession.activeSession.accessTokenData accessToken ] error:error];
                }];
            }
            else {
                NSDictionary *fbAccount = [self.facebookAccounts objectAtIndex:buttonIndex-1];
                [[FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@",[fbAccount objectForKey:@"id"]] ] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *page, NSError *error) {
                    //need to do this nested so we can get the (validated) email
                    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                        [SVProgressHUD dismiss];
                        [user setObject:[page objectForKey:@"name"] forKey:@"name"];
                        [self receiveGraphConnection:connection userDictionary:page token:[fbAccount objectForKey:@"access_token"] error:error];
                    }];
                }];
            }
        }
    }
}

@end
