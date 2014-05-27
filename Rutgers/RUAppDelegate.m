
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
#import <NUISettings.h>


#define MEMORY_MEGS 10
#define DISK_MEGS 25

@interface RUAppDelegate ()
@property RURootController *rootController;
@end

@implementation RUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initCache];
    
   //  [NUISettings init];
    
    [self initAppearance];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    
    [self.window makeKeyAndVisible];

    self.rootController = [[RURootController alloc] init];
    self.window.rootViewController = [self.rootController makeRootViewController];

    return YES;
}

-(void)initAppearance{


}

-(void)initCache{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesFolder = paths[0];
    NSString *fullPath = [cachesFolder stringByAppendingPathComponent:@"RUNetCache"];
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:MEMORY_MEGS * 1024 * 1024 diskCapacity:DISK_MEGS * 1024 * 1024 diskPath:fullPath];
    [NSURLCache setSharedURLCache:URLCache];

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
