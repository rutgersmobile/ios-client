//
//  RUAppDelegate.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

/*
    Descripts : 
        Set up the Root View Controller
 
 
 
 */

#import "RUAppDelegate.h"
#import "XMLDictionary.h"
#import "RUMOTDManager.h"
#import "RURootController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "PureLayout.h"
#import "RUAppearance.h"
#import "RUAnalyticsManager.h"
#import "RUUserInfoManager.h"

@import Firebase;

@interface RUAppDelegate () <UITabBarControllerDelegate>
@property (nonatomic) RUUserInfoManager *userInfoManager;
@property RURootController *rootController;
@property (nonatomic) UIImageView *windowBackground;

@end

@implementation RUAppDelegate
#pragma mark Initialization
/**
 *  Setup application wide appearance, application wide cache, drawer, network monitoring, ask the user for their information if this is the first run, and send the proper analytics events.
 
    Starting point for the app
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    NSSetUncaughtExceptionHandler(&handleUncaughtException);

    NSURLCache* sharedCache = [[NSURLCache alloc]
        initWithMemoryCapacity:2 * 1024 * 1024
        diskCapacity:100 * 1024 * 1024
        diskPath:nil
    ];
    [NSURLCache setSharedURLCache:sharedCache];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;  // the circular spining icon ..
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    [application setStatusBarHidden:YES];
    [FIRApp configure];
    
        // set up apperance
    [RUAppearance applyAppearance];
 
   /*
        This sets up the RUMenuViewController which sets up the menu bar
    */
    [self initializeDrawer];
   
    self.userInfoManager = [[RUUserInfoManager alloc] init];
    [self.userInfoManager getUserInfoIfNeededWithCompletion:^{
        [[RUAnalyticsManager sharedManager] queueEventForApplicationLaunch];
        [self.rootController openDrawerIfNeeded];
    }];
    
    [[RUMOTDManager sharedManager] showMOTD];

    NSArray* item = [[NSUserDefaults standardUserDefaults] objectForKey:CrashKey];
    if (item != nil) {
        [[RUAnalyticsManager sharedManager] postAnalyticsEvents:[item copy]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CrashKey];
    }
    
    return YES;
}

void handleUncaughtException(NSException* exception) {
    // Add exception to analytics and rethrow
    [[RUAnalyticsManager sharedManager] saveException:exception];
    @throw exception;
}

/* This is the entry point for application deep links from the ios system */
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [self.rootController openURL:url];
       return YES;
}

/**
 *  Initialize the main application window, then setup the root controller that communicates between the channel manager and the menu/drawer containment view controller
 */
-(void)initializeDrawer
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; // set up the window
   
   // set up the root view controller for the navigatrional controller
    self.rootController = [[RURootController alloc] init];
    
    self.window.rootViewController = self.rootController.containerViewController;

    [self.window makeKeyAndVisible]; // set up window
    [self.window addSubview:self.windowBackground]; // windowBack refers to the black/ grey background of the app , seen when using the menu to see the slide view
    
    // set up 
    [self.windowBackground autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self.window sendSubviewToBack:self.windowBackground];
    
    self.rootController.containerViewController.view.backgroundColor = [UIColor clearColor]; // clear color allows us to see the windowBackground
}

- (UIImageView *)windowBackground
{
    if (!_windowBackground) {
        
        _windowBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]]; // bg is present in the image assets -> the background of the slide view
        _windowBackground.contentMode = UIViewContentModeScaleToFill; // set up
    }
    return _windowBackground;
}

/**
 *  Resets the app, clearing the cache, the saved information in NSUserDefaults, and then prompts the user to reenter their campus and role.
 */
-(void)resetApp{
    [RUUserInfoManager resetApp];
    [self.userInfoManager getUserInfoIfNeededWithCompletion:nil];
}

-(void)clearCache{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark Lifecycle

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
