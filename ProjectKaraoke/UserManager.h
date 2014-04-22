//
//  UserManager.h
//  ProjectKaraoke
//
//  Created by Lance Fu on 2014-04-22.
//  Copyright (c) 2014 LanceFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

typedef void (^RequestFacebookPermissionCompletionCallback)(void);

// Facebook related functions
+ (void)requestForFacebookReadPermissions:(NSArray *)permissionsNeeded withCompletionCallback:(RequestFacebookPermissionCompletionCallback)completionCallback;
+ (void)requestForFacebookPublishPermissions:(NSArray *)permissionsNeeded withCompletionCallback:(RequestFacebookPermissionCompletionCallback)completionCallback;

@end
