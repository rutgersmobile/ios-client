
//
//  RUAppDelegate.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUAppDelegate.h"
#import "XMLDictionary.h"
#import "RURootController.h"
#import "RUAppearance.h"

#import "RUChannelManager.h"
#import "RUUserInfoManager.h"

@interface RUAppDelegate () <UITabBarControllerDelegate>
@property RURootController *rootController;
@property (nonatomic) UIImageView *windowBackground;
@end

@implementation RUAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    [self initialize];
   
    return YES;
}

/**
 *  Setup application wide appearance, application wide cache, drawer, and also ask the user for their information if this is the first run
 */
-(void)initialize{
    
    [RUAppearance applyAppearance];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self initializeCache];
    [self initializeDrawer];

    [self askUserForInformationIfNeeded];
}

/**
 *  Initialize the cache with the below sizes for memory and disk
 */
#define MEMORY_MEGS 20
#define DISK_MEGS 40

-(void)initializeCache{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesFolder = paths[0];
    NSString *fullPath = [cachesFolder stringByAppendingPathComponent:@"RUNetCache"];
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:MEMORY_MEGS * 1024 * 1024 diskCapacity:DISK_MEGS * 1024 * 1024 diskPath:fullPath];
    [NSURLCache setSharedURLCache:URLCache];
}

/**
 *  Initialize the main application window, then setup the root controller that communicates between the channel manager and the drawer view controller
 */
-(void)initializeDrawer{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.rootController = [[RURootController alloc] init];
    self.window.rootViewController = [self.rootController makeRootViewController];

    [self.window makeKeyAndVisible];
    [self.window addSubview:self.windowBackground];
    [self.window sendSubviewToBack:self.windowBackground];
}

- (UIImageView *)windowBackground
{
    if (!_windowBackground) {
        _windowBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    }
    return _windowBackground;
}

/**
 *  If the user has not yet entered their campus or affiliation, prompt them to enter it, and upon completion open the drawer
 */
-(void)askUserForInformationIfNeeded{
    dispatch_block_t openDrawer = ^{
        [self.rootController openDrawer];
    };
    
    RUUserInfoManager *userInfoManager = [RUUserInfoManager sharedInstance];
    if (![userInfoManager hasUserInformation]) {
        [userInfoManager getUserInformationCancellable:NO completion:openDrawer];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            openDrawer();
        });
    }
}

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
