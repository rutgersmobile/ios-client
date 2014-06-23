//
//  RUUserInfoManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"


@interface RUUserInfoManager () <UIActionSheetDelegate>
@property UIActionSheet *campusActionSheet;
@property UIActionSheet *userTypeActionSheet;

@property NSArray *campusTitles;
@property NSArray *campusTags;

@property NSArray *userTypeTitles;
@property NSArray *userTypeTags;

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
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{userInfoManagerHasInfoKey : @(NO)}];
        
        self.campusTitles = @[@"New Brunswick", @"Newark", @"Camden", @"RBHS", @"Other"];
        self.campusTags = @[@"nb", @"nwk", @"cam", @"rbhs", @"other"];
        
        self.userTypeTitles = @[@"Undergraduate Student", @"Graduate Student", @"Prospective Student", @"Faculty/Staff", @"Parent", @"Alumni", @"Friend"];
        self.userTypeTags = @[@"undergrad", @"grad", @"prospective", @"facstaff", @"parent", @"alumni", @"friend"];

    }
    return self;
}

-(BOOL)hasUserInformation{
    return [[NSUserDefaults standardUserDefaults] boolForKey:userInfoManagerHasInfoKey];
}

-(void)getUserInformationCompletion:(void(^)())completion{
    self.campusActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please select your campus" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *campusTitle in self.campusTitles) {
        [self.campusActionSheet addButtonWithTitle:campusTitle];
    }
    
    self.userTypeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please select your role" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *userTypeTitle in self.userTypeTitles) {
        [self.userTypeActionSheet addButtonWithTitle:userTypeTitle];
    }
    [self presentActionSheet:self.campusActionSheet];

    self.completion = completion;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (actionSheet == self.campusActionSheet) {
        [defaults setObject:self.campusTags[buttonIndex] forKey:userInfoManagerCampusTagKey];
        [self presentActionSheet:self.userTypeActionSheet];
    } else if (actionSheet == self.userTypeActionSheet) {
        [defaults setObject:self.userTypeTags[buttonIndex] forKey:userInfoManagerUserTypeKey];
        [defaults setBool:YES forKey:userInfoManagerHasInfoKey];
        [defaults synchronize];
        if (self.completion) {
            self.completion();
            self.completion = nil;
        }
    }
}
-(void)presentActionSheet:(UIActionSheet *)actionSheet{
    [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
}
@end
