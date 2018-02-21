//
//  RUUserInfoManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUUserInfoManager.h"
#import "Rutgers-Swift.h"

// Constants to manage notifications
NSString *const userInfoManagerDidChangeInfoKey = @"userInfoManagerDidChangeInfoKey";
static NSString *const userInfoManagerCampusKey = @"userInfoManagerCampusKey";
static NSString *const userInfoManagerUserRoleKey = @"userInfoManagerUserRoleKey";

//static NSString *const userInfoManagerFavoritesKey = @"userInfoManagerFavoritesKey";
//NSString *const userInfoManagerDidChangeFavoritesKey = @"userInfoManagerDidChangeFavoritesKey";

@interface RUUserInfoManager () <UIActionSheetDelegate>
@property UIActionSheet *campusActionSheet;
@property UIActionSheet *userTypeActionSheet;

@property (copy) dispatch_block_t completion;   // Block used to obtain information from the user in a non over lapping manner ?? If block is active ,

@property (nonatomic, readonly) BOOL hasUserInformation;
-(void)getUserInformationCompletion:(dispatch_block_t)completion;
@end

/*
    Maintain a manager with default information and preferences of the user. 
        The favourites are stored within the user manager and they are displayed by another class <q> 
        The favourties are stored within NSUserDefaults
 */

/*
 Descipt : 
    Maintain loading preferences.
    Make user select Campus + Studen Type
 */
@implementation RUUserInfoManager

+(void)performInCampusPriorityOrderWithNewBrunswickBlock:(dispatch_block_t)newBrunswickBlock newarkBlock:(dispatch_block_t)newarkBlock camdenBlock:(dispatch_block_t)camdenBlock
{
    NSDictionary *campus = [self currentCampus];
    NSString *tag = campus[@"tag"];
    
    //in case the inputs were nil
    newBrunswickBlock = ^{ if (newBrunswickBlock) newBrunswickBlock(); };  // if the input is nul , then replace the nil by an empty block {}
    newarkBlock = ^{ if (newarkBlock) newarkBlock(); };
    camdenBlock = ^{ if (camdenBlock) camdenBlock(); };
    
    
    // Different Priority
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
             @{@"title" : @"Other", @"tag" : @"other"}       //     Is there a need for another campus ? Verify ..
             ];
}


// Obtain the Campus using the tar
+(NSDictionary *)campusWithTag:(NSString *)tag
{
    for (NSDictionary *campus in self.campuses) {
        if ([campus[@"tag"] isEqualToString:tag]) return campus;
    }
    return nil;
}


// Obtain the campus from user defaults
+(NSDictionary *)currentCampus
{
    NSString *tag = [[NSUserDefaults standardUserDefaults] stringForKey:userInfoManagerCampusKey];
    return [self campusWithTag:tag];
}


// Set the defaults for future use.
+(void)setCurrentCampus:(NSDictionary *)currentCampus
{
    [[NSUserDefaults standardUserDefaults] setObject:currentCampus[@"tag"] forKey:userInfoManagerCampusKey];
    [self notifyInfoDidChange];
}

+(void)notifyInfoDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:userInfoManagerDidChangeInfoKey object:nil];
}

// NSAarray of NSDicts
+(NSArray *)userRoles
{
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

// Get user role for tag
+(NSDictionary *)userRolesWithTag:(NSString *)tag
{
    for (NSDictionary *userRole in self.userRoles)
    {
        if ([userRole[@"tag"] isEqualToString:tag]) return userRole;
    }
    return nil;
}

// Defauls Value Similar to the Campus
+(NSDictionary *)currentUserRole
{
    NSString *tag = [[NSUserDefaults standardUserDefaults] stringForKey:userInfoManagerUserRoleKey];
    return [self userRolesWithTag:tag];
}

+(void)setCurrentUserRole:(NSDictionary *)currentUserRole{
    [[NSUserDefaults standardUserDefaults] setObject:currentUserRole[@"tag"] forKey:userInfoManagerUserRoleKey];
}


// Detemine if the defaults have been set by the user
-(BOOL)hasUserInformation{
    return [[self class] currentCampus] && [[self class] currentUserRole];
}

// If the defaults have not been set , then ask the user for the defaults.
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
    
    [self presentActionSheet:self.campusActionSheet];  // after the campus has been selected , the role action sheet will be displayed

}

// Create the action sheets to be presented individually
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
    
    if (actionSheet == self.campusActionSheet) {  // after the campus has been selected, ask for the role
        
        [[self class] setCurrentCampus:[[self class] campuses][buttonIndex]];
        [self presentActionSheet:self.userTypeActionSheet];

    } else if (actionSheet == self.userTypeActionSheet) { // after the role , call completion block
        
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
    [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window].rootViewController.view]; // read docs
}

// Maintain Favouites Icons in the App ??
/*
+(NSArray <NSDictionary *>*)favorites{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:userInfoManagerFavoritesKey];
}

+(void)setFavorites:(NSArray <NSDictionary *>*)favorites{
    [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:userInfoManagerFavoritesKey];
    [self notifyFavoritesChanged];
}

// add new favourites to the property
+(void)addFavorite:(NSDictionary *)favorite{
    NSArray *favorites = [NSArray arrayWithArray:[self favorites]];
    NSLog(@"%@",favorite);
    if ([favorites containsObject:favorite]) return;
    [self setFavorites:[favorites arrayByAddingObject:favorite]];
}

+(void)removeFavorite:(NSDictionary *)favorite{
    NSMutableArray *favorites = [[self favorites] mutableCopy];
    [favorites removeObject:favorite];
    [self setFavorites:favorites];
}
*/

+(void)notifyFavoritesChanged{
    #warning fix this
    //[[NSNotificationCenter defaultCenter] postNotificationName:MenuItemManagerDidChangeActiveMenuItemsKey object:self];
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
