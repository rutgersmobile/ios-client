//
//  RUMOTDManager.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/8/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

/*
    Descript : 
        Deals with Netorking ??
    Ask Aaron MOTD
 
 
 Shared Manager :
 
 
 */
#import "RUMOTDManager.h"
#import "RUNetworkManager.h"
#import "RUChannelManager.h"

@interface RUMOTDManager ()
@property UIViewController *presentedViewController;
@end

@implementation RUMOTDManager
+(instancetype)sharedManager
{
    static RUMOTDManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedManager = [[RUMOTDManager alloc] init];
    });
    return sharedManager;
}

-(void)showMOTD
{
    
    [[RUNetworkManager sessionManager] GET:@"motd.txt" parameters:nil progress:nil
     
         success:^
     (NSURLSessionDataTask *task, id responseObject)
        {
            if (![responseObject isKindOfClass:[NSDictionary class]]) return;
            
            id data = responseObject[@"data"];
            self.serverInfoString = responseObject[@"motd"];
            
            NSLog(@"MOTD log message: %@",self.serverInfoString);
            
            if ([data isKindOfClass:[NSString class]])
            {
                dispatch_async(dispatch_get_main_queue(),^
                {
                    [self showMOTDResponse:responseObject];
                });
            }
            
        }
     
         failure:^
     (NSURLSessionDataTask *task, NSError *error)
        {
            NSLog(@"Failure retrieving MOTD");
        }
     ];
}

-(void)showMOTDResponse:(id)responseObject
{
    BOOL isWindow = [responseObject[@"isWindow"] boolValue];
    BOOL hasCloseButton = [responseObject[@"hasCloseButton"] boolValue];
    
    NSString *title = responseObject[@"title"];
    NSString *message = responseObject[@"data"];
   
    //more logic that aaron described
    //hasCloseButton = YES;
    //isWindow = YES;
    
    if (isWindow) {
        NSDictionary *textChannel = @{@"title" : title, @"view" : @"text", @"data" : message, @"centersText" : @YES};
        UIViewController *textVC = [[RUChannelManager sharedInstance] viewControllerForChannel:textChannel];
        if (hasCloseButton) textVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        UIViewController *navVC = [[UINavigationController alloc] initWithRootViewController:textVC];
        self.presentedViewController = navVC;
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navVC animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:hasCloseButton ? @"Ok" : nil, nil] show];
    }
}

-(void)done
{
    [self.presentedViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.presentedViewController = nil;
}

@end
