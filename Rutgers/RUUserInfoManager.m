//
//  RUUserInfoManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"

NSString *const userInfoManagerDidChangeInfoKey = @"userInfoManagerDidChangeInfoKey";
static NSString *const userInfoManagerCampusKey = @"userInfoManagerCampusKey";
static NSString *const userInfoManagerUserRoleKey = @"userInfoManagerUserRoleKey";

static NSString *const userInfoManagerFavoritesKey = @"userInfoManagerFavoritesKey";
NSString *const userInfoManagerDidChangeFavoritesKey = @"userInfoManagerDidChangeFavoritesKey";

@interface RUUserInfoManager () <UIActionSheetDelegate>
@property UIActionSheet *campusActionSheet;
@property UIActionSheet *userTypeActionSheet;

@property (copy) dispatch_block_t completion;

@property (nonatomic, readonly) BOOL hasUserInformation;
-(void)getUserInformationCompletion:(dispatch_block_t)completion;
@end

@implementation RUUserInfoManager
+(void)performInCampusPriorityOrderWithNewBrunswickBlock:(dispatch_block_t)newBrunswickBlock newarkBlock:(dispatch_block_t)newarkBlock camdenBlock:(dispatch_block_t)camdenBlock{
    NSDictionary *campus = [self currentCampus];
    NSString *tag = campus[@"tag"];
    
    //in case the inputs were nil
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

+(NSArray *)campuses{
    return @[
             @{@"title" : @"New Brunswick", @"tag" : @"NB"},
             @{@"title" : @"Newark" , @"tag" : @"NK"},
             @{@"title" : @"Camden", @"tag" : @"CM"},
             @{@"title" : @"RBHS", @"tag" : @"RBHS"},
             @{@"title" : @"Other", @"tag" : @"other"}
             ];
}

+(NSDictionary *)campusWithTag:(NSString *)tag{
    for (NSDictionary *campus in self.campuses) {
        if ([campus[@"tag"] isEqualToString:tag]) return campus;
    }
    return nil;
}

+(NSDictionary *)currentCampus{
    NSString *tag = [[NSUserDefaults standardUserDefaults] stringForKey:userInfoManagerCampusKey];
    return [self campusWithTag:tag];
}

+(void)setCurrentCampus:(NSDictionary *)currentCampus{
    [[NSUserDefaults standardUserDefaults] setObject:currentCampus[@"tag"] forKey:userInfoManagerCampusKey];
    [self notifyInfoDidChange];
}

+(void)notifyInfoDidChange{
    [[NSNotificationCenter defaultCenter] postNotificationName:userInfoManagerDidChangeInfoKey object:nil];
}

+(NSArray *)userRoles{
    return @[
             @{@"title" : @"Undergraduate Student", @"tag" : @"UG"},
             @{@"title" : @"Graduate Student", @"tag" : @"G"},
             @{@"title" : @"Prospective Student", @"tag" : @"prospective"},
             @{@"title" : @"Faculty/Staff", @"tag" : @"facstaff"},
             @{@"title" : @"Parent", @"tag" : @"parent"},
             @{@"title" : @"Alumni", @"tag" : @"alumni"},
             @{@"title" : @"Friend", @"tag" : @"friend"}
             ];
}

+(NSDictionary *)userRolesWithTag:(NSString *)tag{
    for (NSDictionary *userRole in self.userRoles) {
        if ([userRole[@"tag"] isEqualToString:tag]) return userRole;
    }
    return nil;
}

+(NSDictionary *)currentUserRole{
    NSString *tag = [[NSUserDefaults standardUserDefaults] stringForKey:userInfoManagerUserRoleKey];
    return [self userRolesWithTag:tag];
}

+(void)setCurrentUserRole:(NSDictionary *)currentUserRole{
    [[NSUserDefaults standardUserDefaults] setObject:currentUserRole[@"tag"] forKey:userInfoManagerUserRoleKey];
}

-(BOOL)hasUserInformation{
    return [[self class] currentCampus] && [[self class] currentUserRole];
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
 *  @param completion A block to be executed upon completion
 */
-(void)getUserInformationCompletion:(dispatch_block_t)completion{
    NSAssert(!self.completion, @"Starting an information request while another is already in progress");
    self.completion = completion;
    
    [self makeActionSheets];
    
    [self presentActionSheet:self.campusActionSheet];

}

-(void)makeActionSheets{
    
    self.campusActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please choose your campus." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSDictionary *campus in [[self class] campuses]) {
        [self.campusActionSheet addButtonWithTitle:campus[@"title"]];
    }
    
    self.userTypeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please indicate your role at the university." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSDictionary *userRole in [[self class] userRoles]) {
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
        
        [[self class] setCurrentCampus:[[self class] campuses][buttonIndex]];
        [self presentActionSheet:self.userTypeActionSheet];

    } else if (actionSheet == self.userTypeActionSheet) {
        
        [[self class] setCurrentUserRole:[[self class] userRoles][buttonIndex]];
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
    [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window].rootViewController.view];
}

+(NSArray <NSDictionary *>*)favorites{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:userInfoManagerFavoritesKey];
}

+(void)setFavorites:(NSArray <NSDictionary *>*)favorites{
    [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:userInfoManagerFavoritesKey];
    [self notifyFavoritesChanged];
}

+(void)notifyFavoritesChanged{
    [[NSNotificationCenter defaultCenter] postNotificationName:userInfoManagerDidChangeFavoritesKey object:self];
}

+(void)addFavorite:(NSDictionary *)favorite{
    NSArray *favorites = [NSArray arrayWithArray:[self favorites]];
    if ([favorites containsObject:favorite]) return;
    [self setFavorites:[favorites arrayByAddingObject:favorite]];
}

+(void)removeFavorite:(NSDictionary *)favorite{
    NSMutableArray *favorites = [[self favorites] mutableCopy];
    [favorites removeObject:favorite];
    [self setFavorites:favorites];
}

/**
 *  Resets the app, clearing the cache, the saved information in NSUserDefaults, and then prompts the user to reenter their campus and role.
 */
+(void)resetApp{
    [self clearCache];
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self notifyFavoritesChanged];
}

+(void)clearCache{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
