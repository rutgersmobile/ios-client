//
//  OptionsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "OptionsDataSource.h"
#import "StringDataSource.h"
#import "AlertDataSource.h"
#import "RUAppDelegate.h"
#import "PreferencesDataSource.h"

@implementation OptionsDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *campusPlaceholderText = [RUUserInfoManager currentCampus][@"title"];
        if (!campusPlaceholderText) campusPlaceholderText = @"Please choose your campus";
        AlertDataSource *campuses = [[AlertDataSource alloc] initWithInitialText:campusPlaceholderText alertButtonTitles:[[RUUserInfoManager campuses] valueForKey:@"title"]];
        campuses.title = @"Select Campus";
        campuses.alertTitle = @"Please choose your campus";
        campuses.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
            [RUUserInfoManager setCurrentCampus:[RUUserInfoManager campuses][buttonIndex]];
        };
        
        NSString *userRolesPlaceholderText = [RUUserInfoManager currentUserRole][@"title"];
        if (!userRolesPlaceholderText) userRolesPlaceholderText = @"Please indicate your role at the university";
        AlertDataSource *userRoles = [[AlertDataSource alloc] initWithInitialText:userRolesPlaceholderText alertButtonTitles:[[RUUserInfoManager userRoles] valueForKey:@"title"]];
        userRoles.title = @"Select Role";
        userRoles.alertTitle = @"Please indicate your role at the university";
        userRoles.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex){
            [RUUserInfoManager setCurrentUserRole:[RUUserInfoManager userRoles][buttonIndex]];
        };
        
        [self addDataSource:campuses];
        [self addDataSource:userRoles];
        
        
        AlertDataSource *reset = [[AlertDataSource alloc] initWithInitialText:@"Reset App" alertButtonTitles:@[@"Yes, I am sure."]];
        reset.alertTitle = @"Are you sure you wish to reset the app?";
        reset.updatesInitialText = NO;
        reset.showsDisclosureIndicator = YES;
        reset.footer = [NSString stringWithFormat:@"Rutgers Mobile Application\nVersion: %@\nAPI: %@",
                        @"4.0.0",
                        @"1.1"];
        
        __weak typeof(self) weakSelf = self;
        reset.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            [weakSelf resetApp];
        };
        [self addDataSource:reset];

        
        StringDataSource *legal = [[StringDataSource alloc] initWithItems:@[@"Legal Notices"]];
        legal.showsDisclosureIndicator = YES;
        
        [self addDataSource:legal];

    }
    return self;
}

-(void)resetApp{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [((RUAppDelegate *)[UIApplication sharedApplication].delegate).userInfoManager getUserInfoIfNeededWithCompletion:nil];
}
@end
