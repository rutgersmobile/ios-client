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
#import "RUMOTDManager.h"
#import "RUUserInfoManager.h"
#import "RUDefines.h"

@implementation OptionsDataSource
/**
 *  Initializes the Options Data Source
 *
 *  @return The initialized Options Data Source
 *  
 *  Descript : 
 *      This Data source is used later on when the options are displayed.
 */
- (instancetype)init
{
    self = [super init];
    if (self)
    {
      
        
        
        // Set up an Alert Data Source and then add it to the data source : The order in which the data is added will determine the layout order
        StringDataSource *editChannels = [[StringDataSource alloc] initWithItems:@[@"Edit Channels"]];
        editChannels.showsDisclosureIndicator = YES;
        [self addDataSource:editChannels];
   
        
        
        
        //Select Campus
        //Get the current campus title or use placeholder text
        NSString *campusInitialText = [RUUserInfoManager currentCampus][@"title"];
        if (!campusInitialText) campusInitialText = @"Please choose your campus";
       
        
        
        

        //Make alert data source with an array of campus titles
        AlertDataSource *campuses = [[AlertDataSource alloc] initWithInitialText:campusInitialText alertButtonTitles:[[RUUserInfoManager campuses] valueForKey:@"title"]];
        campuses.title = @"Select Campus";
        campuses.alertTitle = @"Please choose your campus";
        campuses.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex)
        {
            //On selection, set this campus to be the current campus
            [RUUserInfoManager setCurrentCampus:[RUUserInfoManager campuses][buttonIndex]];
        };
       
        

        //Select Role
        //Get the current user role or use placeholder text
        NSString *userRolesInitialText = [RUUserInfoManager currentUserRole][@"title"];
        if (!userRolesInitialText) userRolesInitialText = @"Please indicate your role at the university";
        
        //Make the alert data source with an array of user role titles
        AlertDataSource *userRoles = [[AlertDataSource alloc] initWithInitialText:userRolesInitialText alertButtonTitles:[[RUUserInfoManager userRoles] valueForKey:@"title"]];
        userRoles.title = @"Select Role";
        userRoles.alertTitle = @"Please indicate your role at the university";
        userRoles.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex)
        {
            //On selection, set this user role to be the current role
            [RUUserInfoManager setCurrentUserRole:[RUUserInfoManager userRoles][buttonIndex]];
        };
        
        [self addDataSource:campuses]; // campus will appear first
        [self addDataSource:userRoles];
       
        
        
        
        //Reset App
        AlertDataSource *reset = [[AlertDataSource alloc] initWithInitialText:@"Reset App" alertButtonTitles:@[@"Yes, I am sure."]];
        reset.alertTitle = @"Are you sure you wish to reset the app?";
        reset.updatesInitialText = NO;
        reset.showsDisclosureIndicator = YES;
        
        NSString *serverInfoString = [RUMOTDManager sharedManager].serverInfoString;
        if (!serverInfoString) serverInfoString = @"Rutgers Mobile Application";
        
        reset.footer = [NSString stringWithFormat:@"%@\nVersion: %@\nAPI: %@",
                        serverInfoString,
                        gittag,
                        api];
        
        reset.alertAction = ^(NSString *buttonTitle, NSInteger buttonIndex) {
            [((RUAppDelegate *)[UIApplication sharedApplication].delegate) resetApp];
        };
        [self addDataSource:reset];

     
//            Seperate ViewController has been created for this
        //Legal Notices
        StringDataSource *legal = [[StringDataSource alloc] initWithItems:@[@"Legal Notices"]];
        legal.showsDisclosureIndicator = YES;
        
        [self addDataSource:legal];

    }
    return self;
}

@end
