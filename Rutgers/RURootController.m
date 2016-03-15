//
//  RURootViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURootController.h"
#import "RUMenuViewController.h"

#import "RUUserInfoManager.h"
#import "RUNavigationController.h"
#import "TableViewController_Private.h"
#import <MMDrawerController.h>
#import "RUChannelManager.h"
#import "NSDictionary+Channel.h"
#import "RUAppearance.h"

@interface RURootController () <RUMenuDelegate>
@property (nonatomic) RUMenuViewController *menuViewController;
@property (nonatomic) UIBarButtonItem *menuBarButtonItem;
@end

@implementation RURootController
+(instancetype)sharedInstance{
    static RURootController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedItem = [RUChannelManager sharedInstance].lastChannel;
        self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(openDrawer)];
    }
    return self;
}

-(Class)drawerClass{
    return [MMDrawerController class];
}

@synthesize containerViewController = _containerViewController;
-(UIViewController <RUContainerController> *)containerViewController{
    if (!_containerViewController) {
        UIViewController *centerViewController = [self topViewControllerForChannel:self.selectedItem];
        
        Class drawerClass = [self drawerClass];
        if (![drawerClass conformsToProtocol:@protocol(RUContainerController)]) [NSException raise:NSInvalidArgumentException format:@"%@ does not conform to %@",NSStringFromClass(drawerClass), NSStringFromProtocol(@protocol(RUContainerController))];
        
        __weak typeof(self) weakSelf = self;
        _containerViewController = [((id)drawerClass) performSelector:@selector(containerWithContainedViewController:drawerViewController:) withObject:centerViewController withObject:self.menuViewController];
        [_containerViewController setDrawerShouldOpenBlock:^BOOL{
            return [weakSelf drawerShouldOpen];     
        }];
    }
    return _containerViewController;
}

-(RUMenuViewController *)menuViewController{
    if (!_menuViewController) {
        _menuViewController = [[RUMenuViewController alloc] init];
        _menuViewController.title = @"Menu";
        _menuViewController.delegate = self;
    }
    return _menuViewController;
}

-(BOOL)drawerShouldOpen{
    id viewController = self.containerViewController.containedViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = viewController;
        if ([nav.viewControllers count] > 1) {
            return NO;
        }
        viewController = nav.topViewController;
    }
    if ([viewController isKindOfClass:[TableViewController class]]) {
        return ![viewController isSearching];
    }
    return NO;
}

#pragma mark Managing Buttons
- (void)placeButtonInViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        if ([nav.viewControllers count] > 0) viewController = (nav.viewControllers)[0];
    }
    
    UINavigationItem *navigationItem = viewController.navigationItem;
    if (!navigationItem.leftBarButtonItem) navigationItem.leftBarButtonItem = self.menuBarButtonItem;
}

-(void)openURL:(NSURL *)url{
    [self openURL:url destinationTitle:nil];
}

-(void)openURL:(NSURL *)url destinationTitle:(NSString *)title{
    UINavigationController *navController = [[RUNavigationController alloc] init];
    [RUAppearance applyAppearanceToNavigationController:navController];
    navController.viewControllers = [[RUChannelManager sharedInstance] viewControllersForURL:url destinationTitle:title];
    
    [self placeButtonInViewController:navController.topViewController];

    self.containerViewController.containedViewController = navController;
    [self.containerViewController closeDrawer];
}

-(void)openFavorite:(NSDictionary *)favorite{
    [self openURL:[NSURL URLWithString:favorite[@"url"]] destinationTitle:favorite[@"title"]];
}

#pragma mark Drawer Interface
-(UIViewController *)topViewControllerForChannel:(NSDictionary *)channel{
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];

    UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
    [RUAppearance applyAppearanceToNavigationController:navController];
    
    [self placeButtonInViewController:navController];

    return navController;
}

#pragma move last channel logic into channel manager
-(void)openItem:(NSDictionary *)item {
    self.selectedItem = item;
    
    if (item[@"isFavorite"]) {
        [self openFavorite:item];
    } else {
        [RUChannelManager sharedInstance].lastChannel = item;
        self.containerViewController.containedViewController = [self topViewControllerForChannel:item];
    }
}

-(void)openDrawer{
    [self.containerViewController openDrawer];
}

-(void)openDrawerIfNeeded{
    if ([self channelIsSplashChannel:[RUChannelManager sharedInstance].lastChannel]){
        [self.containerViewController openDrawer];
    }
}

-(BOOL)channelIsSplashChannel:(NSDictionary *)channel{
    return [[channel channelView] isEqualToString:@"splash"];
}

#pragma mark Menu Delegate
-(void)menu:(RUMenuViewController *)menu didSelectItem:(NSDictionary *)item{
    if (![item isEqualToDictionary:self.selectedItem]) [self openItem:item];
    [self.containerViewController closeDrawer];
}

@end
