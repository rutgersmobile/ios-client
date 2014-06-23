//
//  RUUserInfoManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const userInfoManagerHasInfoKey = @"userInfoManagerHasInfoKey";
static NSString *const userInfoManagerCampusTagKey = @"userInfoManagerCampusTagKey";
static NSString *const userInfoManagerUserTypeKey = @"userInfoManagerUserTypeKey";


@interface RUUserInfoManager : NSObject
-(BOOL)hasUserInformation;
+(instancetype)sharedInstance;
-(void)getUserInformationCompletion:(void(^)())completion;
@end
