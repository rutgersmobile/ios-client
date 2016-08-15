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
#import <MMDrawerController.h> // NO LONGER USED // HAD TOO MANY ERRORS RELATED TO SHOWING THE EDIT OPTIONS VIEW PROPERLY
#import "RUChannelManager.h"
#import "NSDictionary+Channel.h"
#import "RUAppearance.h"
#import "Rutgers-Swift.h"


// To setup will fail relationship between the swipe gesture in the bus segment contol and the pan gesture to open the drawer
#import "RUBusViewController.h"
#import "SegmentedTableViewController.h"

/**
    RUMenu -> the menu displayed in the slide bar
    RURoot -> The root view controller which displays the differet View Controllers
    RUContainer -> Protocol which is used to customize the drawer and add abstract away the usagd differences between MDDrawer and SWRevel libraries
 
 */

#import <WebKit/WebKit.h>

/*
    AUGUST 2ND :
        WE USE SWREVEL EXCLUSIVELY FOR THE SLIDE MENU
 
 */

@interface RURootController () <RUMenuDelegate>
@property (nonatomic) RUMenuViewController *menuViewController;
@end


@implementation RURootController




/*
    Create a shared instance used for the entirety of the program
    Singleton Class
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
       // self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(openDrawer)]; // revert back to old menu icon.
        UIButton *menuView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [menuView addTarget:self action:@selector(openDrawer) forControlEvents:UIControlEventTouchUpInside];
        [menuView setBackgroundImage:[[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuView];
        
        
    }
    return self;
}



// decide which drawer we are going to use for the class
-(Class)drawerClass
{
        return [SWRevealViewController class];
}

/*
    In RuRootContr...
    This contains the RUMenuViewController and the RUNAvigation ...
    The containerViewController is either the SWRevel View controller or the MDView controller
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
        
        [_containerViewController setDrawerShouldOpenBlock:^BOOL
        {
            return [weakSelf drawerShouldOpen];     
        }];
    
       //   // add the slide gesture recogniser to the view
       if([self drawerClass] == [SWRevealViewController class])
       {
            [_containerViewController.view addGestureRecognizer:((SWRevealViewController *)_containerViewController).panGestureRecognizer];
           ((SWRevealViewController *)_containerViewController).tapGestureRecognizer.cancelsTouchesInView = NO; // inorder to ensure that the tap gesture also is passed to the menu view controller.
           [_containerViewController.view addGestureRecognizer:((SWRevealViewController *)_containerViewController).tapGestureRecognizer];
       
           
           
       // see : https://github.com/John-Lluch/SWRevealViewController/issues/152
       
       }
     
     
    }
    
    return _containerViewController;
}

/*
    The panGestureRecognizer of the slide menu should only work if the swipe gesture for the bus view contoller segmented elements have failed.
    If the segments have been moved then the same gesture should not cause the menu to slide
 
 
 */

-(RUMenuViewController *)menuViewController
{
    if (!_menuViewController)
    {
        _menuViewController = [[RUMenuViewController alloc] init];
        _menuViewController.title = @"Menu";
        _menuViewController.delegate = self;
    }
    return _menuViewController;
}

-(BOOL)drawerShouldOpen
{
    id viewController = self.containerViewController.containedViewController;
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = viewController;
        if ([nav.viewControllers count] > 1)
        {
            return NO;
        }
        viewController = nav.topViewController;
    }
    if ([viewController isKindOfClass:[TableViewController class]])
    {
        return ![viewController isSearching];
    }
    return NO;
}
/*
    Adds a Left Button to top most nav controller
 */
#pragma mark Managing Buttons
- (void)placeButtonInViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
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
-(void)openURL:(NSURL *)url
{
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
-(void)openURL:(NSURL *)url destinationTitle:(NSString *)title
{
    UINavigationController *navController = [[RUNavigationController alloc] init];  // Should a new instance be created ???
    [RUAppearance applyAppearanceToNavigationController:navController];
   
    /*
        This function seems to be the source of error , for the bus etc , one specific way to used to 
        display the controller , but for the dtables another way to present the information is used .
     
     */
    navController.viewControllers = [[RUChannelManager sharedInstance] viewControllersForURL:url destinationTitle:title];
    
    [self placeButtonInViewController:navController.topViewController];

    self.containerViewController.containedViewController = navController;
   
    
    [self.containerViewController closeDrawer];
}



/*
    opens a particular url. openFavourite is simply a wrapper for the openURL function.
 
 */
-(void)openFavorite:(RUFavorite *)favorite
{
    [self openURL:favorite.url destinationTitle:favorite.title];
}

/*
    his sets up the slide view controller
    Get the top view controller for a given channel
    That is get the view controller for a channel. Emebed the channel in a navigation controller and then return the top navigation controller
 */
#pragma mark Drawer Interface
-(UIViewController *)topViewControllerForChannel:(NSDictionary *)channel
{
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
    UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
    [RUAppearance applyAppearanceToNavigationController:navController];
    [self placeButtonInViewController:navController];

    return navController;
}

#pragma move last channel logic into channel manager
-(void)openItem:(id)item
{
    self.selectedItem = item;
    
    if ([item isKindOfClass:[NSDictionary class]])
    {
        [RUChannelManager sharedInstance].lastChannel = item;
        self.containerViewController.containedViewController = [self topViewControllerForChannel:item];
      
    }
    else
    {
        [self openFavorite:item];
    }
    
}

-(void)openDrawer
{
  
    if([self drawerClass] == [SWRevealViewController class])
    {
        [self.containerViewController toogleDrawer]; // use for SWRevel
    }
    else
    {
        [self.containerViewController openDrawer]; // use for MD sldie
    }
    
    NSLog(@"toggle Drawer");
}

-(void)openDrawerIfNeeded
{
    if ([self channelIsSplashChannel:[RUChannelManager sharedInstance].lastChannel])
    {
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
-(void)menu:(RUMenuViewController *)menu didSelectItem:(id)item
{
    if (![item isEqual:self.selectedItem])
    {
        [self openItem:item];
    }
    [self.containerViewController closeDrawer];
}

// Disable user interaction with the front view when the menu has appearer
-(void)menuWillAppear
{
    if([self drawerClass] == [SWRevealViewController class])
        [self.containerViewController.containedViewController.view setUserInteractionEnabled:NO];
}

-(void)menuWillDisappear
{
    if([self drawerClass] == [SWRevealViewController class])
        [self.containerViewController.containedViewController.view setUserInteractionEnabled:YES];
}



@end
