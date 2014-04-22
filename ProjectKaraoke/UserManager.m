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
