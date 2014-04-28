//
//  UserManager.m
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-04-22.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import "UserManager.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation UserManager

+ (BOOL)isLoggedIn {
    return [UserManager authTokenForService:FACEBOOK_SERVICE] != nil;
}


+ (void)clearSavedCredentials {
    [UserManager setAuthToken:nil forService:FACEBOOK_SERVICE];
}


+ (NSString *)authTokenForService:(NSString *)service {
    return [UserManager secureValueForService:service ForKey:PROJECT_KARAOKE_ACCOUNT];
}


+ (void)setAuthToken:(NSString *)authToken forService:(NSString *)service {
    [UserManager setSecureValue:authToken forService:service forKey:PROJECT_KARAOKE_ACCOUNT];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}


+ (void)setSecureValue:(NSString *)value forService:(NSString *)service forKey:(NSString *)key{
    if (value) {
        [SSKeychain setPassword:value
                     forService:service
                        account:key];
    }
    else {
        [SSKeychain deletePasswordForService:service account:key];
    }
}


+ (NSString *)secureValueForService:(NSString *)service ForKey:(NSString *)key {
    return [SSKeychain passwordForService:service account:key];
}


+ (void)logout {
    [FBSession.activeSession closeAndClearTokenInformation];
    [UserManager clearSavedCredentials];
    
    UIStoryboard *storyboard = storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"LandingNavigationController"];
    delegate.window.rootViewController = controller;
}


+ (void)requestForFacebookReadPermissions:(NSArray *)permissionsNeeded withCompletionCallback:(RequestFacebookPermissionCompletionCallback)completionCallback {
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSDictionary *currentPermissions = [(NSArray *)[result data] objectAtIndex:0];
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  for (NSString *permission in permissionsNeeded) {
                                      if (![currentPermissions objectForKey:permission]) {
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  if ([requestPermissions count] > 0) {
                                      [FBSession.activeSession requestNewReadPermissions:requestPermissions completionHandler:^(FBSession *session, NSError *error) {
                                          if (!error) {
                                              NSLog(@"new permissions %@", [FBSession.activeSession permissions]);
                                              completionCallback();
                                          }
                                          else {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                          }
                                      }];
                                  }
                                  else {
                                      completionCallback();
                                  }
                                  
                              }
                              else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"Error: %@", error);
                              }
                          }];
}


+ (void)requestForFacebookPublishPermissions:(NSArray *)permissionsNeeded withCompletionCallback:(RequestFacebookPermissionCompletionCallback)completionCallback {
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSDictionary *currentPermissions = [(NSArray *)[result data] objectAtIndex:0];
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  for (NSString *permission in permissionsNeeded) {
                                      if (![currentPermissions objectForKey:permission]) {
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  if ([requestPermissions count] > 0) {
                                      [FBSession.activeSession requestNewPublishPermissions:requestPermissions defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                                          if (!error) {
                                              NSLog(@"new permissions %@", [FBSession.activeSession permissions]);
                                              completionCallback();
                                          }
                                          else {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                          }
                                      }];
                                  }
                                  else {
                                      completionCallback();
                                  }
                                  
                              }
                              else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"Error: %@", error);
                              }
                          }];
}

@end
