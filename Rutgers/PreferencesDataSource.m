//
//  PreferencesDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "PreferencesDataSource.h"
#import "AlertDataSource.h"

@interface PreferencesDataSource ()
@end

@implementation PreferencesDataSource
-(instancetype)init{
    self = [super init];
    if (self) {
        RUUserInfoManager *userInfoManager = [RUUserInfoManager sharedInstance];
        
        NSString *campusPlaceholderText = userInfoManager.campus[@"title"];
        if (!campusPlaceholderText) campusPlaceholderText = @"Please choose your campus";
        AlertDataSource *campuses = [[AlertDataSource alloc] initWithInitialText:campusPlaceholderText alertButtonTitles:[userInfoManager.campuses valueForKey:@"title"]];
        campuses.title = @"Campus";
        campuses.alertTitle = @"Please choose your campus";
        campuses.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
            userInfoManager.campus = userInfoManager.campuses[buttonIndex];
        };
        
        NSString *userRolesPlaceholderText = userInfoManager.userRole[@"title"];
        if (!userRolesPlaceholderText) userRolesPlaceholderText = @"Please indicate your role at the university";
        AlertDataSource *userRoles = [[AlertDataSource alloc] initWithInitialText:userRolesPlaceholderText alertButtonTitles:[userInfoManager.userRoles valueForKey:@"title"]];
        userRoles.title = @"Role";
        userRoles.alertTitle = @"Please indicate your role at the university";
        userRoles.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
            userInfoManager.userRole = userInfoManager.userRoles[buttonIndex];
        };
        
        [self addDataSource:campuses];
        [self addDataSource:userRoles];
    }
    return self;
}
@end
