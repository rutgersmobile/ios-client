//
//  RUAppDelegate.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUAppDelegate.h"
#import "JASidePanelController.h"
#import "RUMenuViewController.h"

@implementation RUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#define MEMORY_MEGS 4
#define DISK_MEGS 8
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesFolder = paths[0];
    NSString *fullPath = [cachesFolder stringByAppendingPathComponent:@"RUNetCache"];
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:MEMORY_MEGS * 1024 * 1024 diskCapacity:DISK_MEGS * 1024 * 1024 diskPath:fullPath];
    [NSURLCache setSharedURLCache:URLCache];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    JASidePanelController * mainViewController = [[JASidePanelController alloc] init];
    
    // TODO: motd, prefs, launch last used channel
    mainViewController.centerPanel = [self makeDefaultScreen];
    
    RUMenuViewController * menu = [[RUMenuViewController alloc] init];
    
    mainViewController.leftPanel = menu;
    
    self.window.rootViewController = mainViewController;
    
    menu.sidepanel = mainViewController;
    
    [self.window makeKeyAndVisible];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [mainViewController showLeftPanelAnimated:YES];
    });
    return YES;
}

- (id) makeDefaultScreen {
    UIViewController * splashViewController = [[UIViewController alloc] init];
    splashViewController.view.backgroundColor = [UIColor whiteColor];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchImage-700"]];
    imageView.frame = [[UIScreen mainScreen] bounds];
    [splashViewController.view addSubview:imageView];
    return splashViewController;
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
