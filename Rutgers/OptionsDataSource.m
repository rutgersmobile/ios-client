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

@implementation OptionsDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        StringDataSource *preferences = [[StringDataSource alloc] initWithItems:@[@"Set Preferences"]];
        preferences.showsDisclosureIndicator = YES;

        StringDataSource *legal = [[StringDataSource alloc] initWithItems:@[@"Legal Notices"]];
        legal.showsDisclosureIndicator = YES;
        
        AlertDataSource *reset = [[AlertDataSource alloc] initWithInitialText:@"Reset App" alertButtonTitles:@[@"Yes, i am sure"]];
        reset.alertTitle = @"Are you sure you wish to reset the app?";
        reset.updatesInitialText = NO;
        reset.showsDisclosureIndicator = YES;
        
        __weak typeof(self) weakSelf = self;
        reset.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            [weakSelf resetApp];
        };
        
        [self addDataSource:preferences];
        [self addDataSource:legal];
        [self addDataSource:reset];

    }
    return self;
}

-(void)resetApp{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[RUUserInfoManager sharedInstance] getUserInfoIfNeededWithCompletion:nil];
}
@end
