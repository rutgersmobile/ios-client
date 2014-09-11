//
//  RUUserInfoManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"

static NSString *const userInfoManagerHasInfoKey = @"userInfoManagerHasInfoKey";
static NSString *const userInfoManagerCampusKey = @"userInfoManagerCampusKey";
static NSString *const userInfoManagerUserRoleKey = @"userInfoManagerUserRoleKey";

@interface RUUserInfoManager () <UIActionSheetDelegate>
@property UIActionSheet *campusActionSheet;
@property UIActionSheet *userTypeActionSheet;

@property NSArray *campuses;
@property NSArray *userRoles;

@property (copy) dispatch_block_t completion;

-(BOOL)hasUserInformation;
-(void)getUserInformationCompletion:(dispatch_block_t)completion;
@end


@implementation RUUserInfoManager

-(void)performInCampusPriorityOrderWithNewBrunswickBlock:(dispatch_block_t)newBrunswickBlock newarkBlock:(dispatch_block_t)newarkBlock camdenBlock:(dispatch_block_t)camdenBlock{
    NSDictionary *campus = self.campus;
    NSString *tag = campus[@"tag"];
    
    newBrunswickBlock = ^{ if (newBrunswickBlock) newBrunswickBlock(); };
    newarkBlock = ^{ if (newarkBlock) newarkBlock(); };
    camdenBlock = ^{ if (camdenBlock) camdenBlock(); };
    
    if ([tag isEqualToString:@"NK"]) {
        newarkBlock();
        newBrunswickBlock();
        camdenBlock();
    } else if ([tag isEqualToString:@"CM"]) {
        camdenBlock();
        newBrunswickBlock();
        newarkBlock();
    } else {
        newBrunswickBlock();
        camdenBlock();
        newarkBlock();
    }
}

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
        
        self.campuses = @[
                          @{@"title" : @"New Brunswick", @"tag" : @"NB"},
                          @{@"title" : @"Newark" , @"tag" : @"NK"},
                          @{@"title" : @"Camden", @"tag" : @"CM"},
                          @{@"title" : @"RBHS", @"tag" : @"RBHS"},
                          @{@"title" : @"Other", @"tag" : @"other"}
                          ];
        
        self.userRoles = @[
                           @{@"title" : @"Undergraduate Student", @"tag" : @"UG"},
                           @{@"title" : @"Graduate Student", @"tag" : @"G"},
                           @{@"title" : @"Prospective Student", @"tag" : @"prospective"},
                           @{@"title" : @"Faculty/Staff", @"tag" : @"facstaff"},
                           @{@"title" : @"Parent", @"tag" : @"parent"},
                           @{@"title" : @"Alumni", @"tag" : @"alumni"},
                           @{@"title" : @"Friend", @"tag" : @"friend"}
                           ];
    }
    return self;
}

-(BOOL)hasUserInformation{
    return [[NSUserDefaults standardUserDefaults] boolForKey:userInfoManagerHasInfoKey];
}
-(void)setHasUserInformation:(BOOL)hasUserInformation{
    [[NSUserDefaults standardUserDefaults] setBool:hasUserInformation forKey:userInfoManagerHasInfoKey];
}

-(NSDictionary *)campus{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:userInfoManagerCampusKey];
}
-(void)setCampus:(NSDictionary *)campus{
    [[NSUserDefaults standardUserDefaults] setObject:campus forKey:userInfoManagerCampusKey];
}

-(NSDictionary *)userRole{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:userInfoManagerUserRoleKey];
}
-(void)setUserRole:(NSDictionary *)userRole{
    [[NSUserDefaults standardUserDefaults] setObject:userRole forKey:userInfoManagerUserRoleKey];
}

-(void)getUserInfoIfNeededWithCompletion:(dispatch_block_t)completion{
    if (![self hasUserInformation]) {
        [self getUserInformationCompletion:completion];
    } else {
        if (completion) completion();
    }
}

/**
 *  Presents the user interface to allow the user to enter their campus or affiliation
 *
 *  @param cancellable Is the user allowed to cancel without entering their information
 *  @param completion A block to be executed when
 */
-(void)getUserInformationCompletion:(dispatch_block_t)completion{
    NSAssert(!self.completion, @"Starting an information request while another is already in progress");
    self.completion = completion;
    
    [self makeActionSheets];
    
    [self presentActionSheet:self.campusActionSheet];

}

-(void)makeActionSheets{
    
    self.campusActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please choose your campus." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSDictionary *campus in self.campuses) {
        [self.campusActionSheet addButtonWithTitle:campus[@"title"]];
    }
    
    self.userTypeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please indicate your role at the university." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSDictionary *userRole in self.userRoles) {
        [self.userTypeActionSheet addButtonWithTitle:userRole[@"title"]];
    }

}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    //this was supposed to present the sheet again if the user tried to dismiss it on ipad when there is no cancel button
    /*
    if (!self.cancellable && buttonIndex == -1) {
        [self presentActionSheet:actionSheet];
        return;
    } else */
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self complete];
        return;
    }
    
    if (actionSheet == self.campusActionSheet) {
        
        [self setCampus:self.campuses[buttonIndex]];
        [self presentActionSheet:self.userTypeActionSheet];

    } else if (actionSheet == self.userTypeActionSheet) {
        
        [self setUserRole:self.userRoles[buttonIndex]];
        [self setHasUserInformation:YES];
        
        [self complete];
    }
}

-(void)complete{
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.completion) {
        self.completion();
        self.completion = nil;
    }
}

-(void)presentActionSheet:(UIActionSheet *)actionSheet{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
    });
}


@end
