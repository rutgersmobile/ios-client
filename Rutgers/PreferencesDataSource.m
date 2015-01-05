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
        
        NSString *campusPlaceholderText = [RUUserInfoManager currentCampus][@"title"];
        if (!campusPlaceholderText) campusPlaceholderText = @"Please choose your campus";
        AlertDataSource *campuses = [[AlertDataSource alloc] initWithInitialText:campusPlaceholderText alertButtonTitles:[[RUUserInfoManager campuses] valueForKey:@"title"]];
        campuses.title = @"Campus";
        campuses.alertTitle = @"Please choose your campus";
        campuses.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
            [RUUserInfoManager setCurrentCampus:[RUUserInfoManager campuses][buttonIndex]];
        };
        
        NSString *userRolesPlaceholderText = [RUUserInfoManager currentUserRole][@"title"];
        if (!userRolesPlaceholderText) userRolesPlaceholderText = @"Please indicate your role at the university";
        AlertDataSource *userRoles = [[AlertDataSource alloc] initWithInitialText:userRolesPlaceholderText alertButtonTitles:[[RUUserInfoManager userRoles] valueForKey:@"title"]];
        userRoles.title = @"Role";
        userRoles.alertTitle = @"Please indicate your role at the university";
        userRoles.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
            [RUUserInfoManager setCurrentUserRole:[RUUserInfoManager userRoles][buttonIndex]];
        };
        
        [self addDataSource:campuses];
        [self addDataSource:userRoles];
    }
    return self;
}
@end
