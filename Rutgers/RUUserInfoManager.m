//
//  RUUserInfoManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"

static NSString *const RUInfoHasUserInfoKey = @"RUInfoHasUserInfoKey";

@interface RUUserInfoManager () <UIActionSheetDelegate>
@property UIActionSheet *campusActionSheet;
@property UIActionSheet *roleActionSheet;
@property (copy) void(^completion)();
@end


@implementation RUUserInfoManager
+(instancetype)sharedInstance{
    static RUUserInfoManager *infoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infoManager = [[RUUserInfoManager alloc] init];
    });
    return infoManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{RUInfoHasUserInfoKey : @(NO)}];
    }
    return self;
}
-(BOOL)hasUserInformation{
    return [[NSUserDefaults standardUserDefaults] boolForKey:RUInfoHasUserInfoKey];
}
-(void)getUserInformationCompletion:(void(^)())completion{
    self.campusActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please select your campus" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Busch",@"Livi", nil];
    self.roleActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please select your role" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Student",@"Parent", nil];

    [self.campusActionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
    self.completion = completion;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet == self.campusActionSheet) {
        [self.roleActionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
    } else if (actionSheet == self.roleActionSheet) {
        self.completion();
        self.completion = nil;
    }
}
@end
