//
//  UserManager.h
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-04-22.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FACEBOOK_SERVICE            @"facebook_service"
#define SOUNDCLOUD_SERVICE          @"soundcloud_service"
#define PROJECT_KARAOKE_ACCOUNT     @"project_karaoke_account"

@interface UserManager : NSObject

typedef void (^RequestFacebookPermissionCompletionCallback)(void);

+ (BOOL)isLoggedIn;
+ (void)clearSavedCredentials;
+ (NSString *)authTokenForService:(NSString *)service;
+ (void)setAuthToken:(NSString *)authToken forService:(NSString *)service;
+ (void)logout;
// Facebook related functions
+ (void)requestForFacebookReadPermissions:(NSArray *)permissionsNeeded withCompletionCallback:(RequestFacebookPermissionCompletionCallback)completionCallback;
+ (void)requestForFacebookPublishPermissions:(NSArray *)permissionsNeeded withCompletionCallback:(RequestFacebookPermissionCompletionCallback)completionCallback;

@end
