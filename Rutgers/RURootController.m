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
#import "Rutgers-Swift.h"

/**
    RUMenu -> the menu displayed in the slide bar
    RURoot -> The root view controller which displays the differet View Controllers
    RUContainer -> Protocol which is used to customize the drawer and add abstract away the usagd differences between MDDrawer and SWRevel libraries
 
 */


@interface RURootController () <RUMenuDelegate>
@property (nonatomic) RUMenuViewController *menuViewController;
@property (nonatomic) UIBarButtonItem *menuBarButtonItem;
@end


@implementation RURootController

/*
    Create a shared instance used for the entirety of the program
 */
+(instancetype)sharedInstance
{
    static RURootController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^
    {
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark initialization

/*
    Set us the view controller from which every other VC is accessed. 
    Also Setup the Menu Item 
 */
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.selectedItem = [RUChannelManager sharedInstance].lastChannel;  //obtain the last selected channel
#warning to do : convert the menu to an icon
       // self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(openDrawer)];
        
        UIButton *menuView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [menuView addTarget:self action:@selector(openDrawer) forControlEvents:UIControlEventTouchUpInside];
        [menuView setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuView];
        
        //self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(openDrawer)];
    }
    return self;
}

// decide which drawer we are going to use for the class
-(Class)drawerClass
{
    return [MMDrawerController class];
}

/*
    In RuRootContr...
 
 
 */
@synthesize containerViewController = _containerViewController;
-(UIViewController <RUContainerController> *)containerViewController
{
    if (!_containerViewController)
    {
        UIViewController *centerViewController = [self topViewControllerForChannel:self.selectedItem];
        
        Class drawerClass = [self drawerClass];
        /*
                RUContainerController is added to the Classes during run time using the category feature
          */
        if (![drawerClass conformsToProtocol:@protocol(RUContainerController)]) [NSException raise:NSInvalidArgumentException format:@"%@ does not conform to %@",NSStringFromClass(drawerClass), NSStringFromProtocol(@protocol(RUContainerController))];
        
        __weak typeof(self) weakSelf = self; // Used within block to prevent memory cycles.
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
/*
    Adds a Left Button to top most nav controller
 */
#pragma mark Managing Buttons
- (void)placeButtonInViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        if ([nav.viewControllers count] > 0) viewController = (nav.viewControllers)[0]; // select the top most viewController ? or is the bottom ? ????? <q>
    }
    
    UINavigationItem *navigationItem = viewController.navigationItem;
    // add the menu bar to the navigation bar of the top most view controller
    if (!navigationItem.leftBarButtonItem) navigationItem.leftBarButtonItem = self.menuBarButtonItem;
}


/*
    Moves to a particular view . The location of the views are maintained as an URL
 
 */
-(void)openURL:(NSURL *)url{
    [self openURL:url destinationTitle:nil];
}

/*
    Descript : 
            Used to Move from The Side Bar to any one of the VC . 
            Also used to handle the Favourites Function of the app;
    @param url : dtable / actual url ???? eg rutgers://bus/route/a/
    @param title : Name of the VC

    Converts the url into a view Controller using the RUChannelMan...
 */
-(void)openURL:(NSURL *)url destinationTitle:(NSString *)title{
    UINavigationController *navController = [[RUNavigationController alloc] init];  // Should a new instance be created ???
    [RUAppearance applyAppearanceToNavigationController:navController];
    
   
    /*
        This function seems to be the source of error , for the bus etc , one specific way to used to 
        display the controller , but for the dtables another way to present the information is used .
     
     */
    navController.viewControllers = [[RUChannelManager sharedInstance] viewControllersForURL:url destinationTitle:title];
    
    [self placeButtonInViewController:navController.topViewController];

    self.containerViewController.containedViewController = navController;
    [self.containerViewController closeDrawer];  // ???? Closing the side view bar ?
}



/*
    opens a particular url. openFavourite is simply a wrapper for the openURL function.
 
 */
-(void)openFavorite:(RUFavorite *)favorite{
    [self openURL:favorite.url destinationTitle:favorite.title];
}

/*
    The slide drawer is build by using MMDrawController lib. 
    This sets up the slide view controller
 
 
 */
#pragma mark Drawer Interface
-(UIViewController *)topViewControllerForChannel:(NSDictionary *)channel{
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];

    UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
    [RUAppearance applyAppearanceToNavigationController:navController];
    
    [self placeButtonInViewController:navController];

    return navController;
}

#pragma move last channel logic into channel manager
-(void)openItem:(id)item {
    self.selectedItem = item;
    
    NSLog(@"%@",item);
    
    if ([item isKindOfClass:[NSDictionary class]]) {
        [RUChannelManager sharedInstance].lastChannel = item;
        self.containerViewController.containedViewController = [self topViewControllerForChannel:item];
    } else {
        [self openFavorite:item];
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

/*
    Select the view to go to
    
    If the user tries to open an already open view , the drawer is just closed.
 */
#pragma mark Menu Delegate
-(void)menu:(RUMenuViewController *)menu didSelectItem:(id)item{
    if (![item isEqual:self.selectedItem]) [self openItem:item];
    [self.containerViewController closeDrawer];
}

@end
