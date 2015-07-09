//
//  RURootViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURootController.h"
#import "RUMenuViewController.h"
#import <SWRevealViewController.h>
#import <MMDrawerController.h>
#import "RUUserInfoManager.h"
#import "RUNavigationController.h"
#import "TableViewController_Private.h"

typedef NS_ENUM(NSUInteger, DrawerImplementation) {
    DrawerImplementationSWReveal,
    DrawerImplementationMMDrawer,
    DrawerImplementationSplitView,
};

@interface RURootController () <RUMenuDelegate>
@property (nonatomic) SWRevealViewController *revealViewController;
@property (nonatomic) MMDrawerController *mmDrawerViewController;
@property (nonatomic) UISplitViewController *splitViewController;

@property (nonatomic) RUMenuViewController *menuViewController;
@property (nonatomic) NSHashTable *managedScrollViews;

@property (nonatomic) UIBarButtonItem *menuBarButtonItem;

@property (nonatomic) UIViewController *centerViewController;
@property (nonatomic, readonly) DrawerImplementation drawerImplementation;
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

-(DrawerImplementation)drawerImplementation{
    return DrawerImplementationMMDrawer;
  //  return iPad() ? DrawerImplementationSplitView : DrawerImplementationMMDrawer;
}

#pragma mark initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.managedScrollViews = [NSHashTable weakObjectsHashTable];
        self.currentChannel = [RUChannelManager sharedInstance].lastChannel;
        self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(openDrawer)];
    }
    return self;
}

@synthesize containerViewController = _containerViewController;
-(UIViewController *)containerViewController{
    if (!_containerViewController) {
        UIViewController *centerViewController = [self topViewControllerForChannel:self.currentChannel];
     //   RUNavigationController *navigationController = [[RUNavigationController alloc] initWithRootViewController:self.menuViewController];
     //   navigationController.preferredStatusBarStyle = UIStatusBarStyleLightContent;
     //   [RUAppearance applyAppearanceToNavigationController:navigationController];
     //   navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.3 alpha:1];
        _containerViewController = [self makeContainerViewControllerWithCenterViewController:centerViewController leftViewController:self.menuViewController];
        [self placeButtonInCenterViewController];
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

-(UIViewController *)makeContainerViewControllerWithCenterViewController:(UIViewController *)centerViewController leftViewController:(UIViewController *)leftViewController{
    
    CGFloat revealWidth = 270;
    if (iPad()) revealWidth = round(revealWidth * IPAD_SCALE);
    CGFloat revealDisplacement = 55;
    NSTimeInterval animationDuration = 0.24;
    
    switch (self.drawerImplementation) {
        case DrawerImplementationSplitView:
            self.splitViewController = [[UISplitViewController alloc] init];
            self.splitViewController.viewControllers = @[leftViewController,centerViewController];
            self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
            self.splitViewController.maximumPrimaryColumnWidth = revealWidth;
            
            return self.splitViewController;
            
        case DrawerImplementationSWReveal:
            self.revealViewController = [[SWRevealViewController alloc] initWithRearViewController:leftViewController frontViewController:centerViewController];
            self.revealViewController.rearViewRevealWidth = revealWidth;
            self.revealViewController.rearViewRevealOverdraw = 0;
            self.revealViewController.rearViewRevealDisplacement = revealDisplacement;
            self.revealViewController.clipsViewsToBounds = YES;
            self.revealViewController.frontViewShadowOpacity = 0;
            self.revealViewController.replaceViewAnimationDuration = animationDuration;
            self.revealViewController.toggleAnimationDuration = animationDuration;
            [self.revealViewController panGestureRecognizer];
            [self.revealViewController tapGestureRecognizer];
            
            return self.revealViewController;

        case DrawerImplementationMMDrawer:
            self.mmDrawerViewController = [[MMDrawerController alloc] initWithCenterViewController:centerViewController leftDrawerViewController:leftViewController];
            
            self.mmDrawerViewController.openDrawerGestureModeMask =
            MMOpenDrawerGestureModeBezelPanningCenterView |
            MMOpenDrawerGestureModePanningNavigationBar;

            self.mmDrawerViewController.closeDrawerGestureModeMask =
            MMCloseDrawerGestureModePanningNavigationBar    |
            MMCloseDrawerGestureModePanningCenterView       |
            MMCloseDrawerGestureModeBezelPanningCenterView  |
            MMCloseDrawerGestureModeTapNavigationBar        |
            MMCloseDrawerGestureModeTapCenterView;
            
            self.mmDrawerViewController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
            self.mmDrawerViewController.maximumLeftDrawerWidth = revealWidth;
            self.mmDrawerViewController.animationVelocity = revealWidth/animationDuration;
            self.mmDrawerViewController.showsShadow = NO;
            
            [self.mmDrawerViewController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
                drawerController.leftDrawerViewController.view.transform = CGAffineTransformMakeTranslation((percentVisible-1)*revealDisplacement, 0);
            }];
            
            __weak typeof(self) weakSelf = self;
            [self.mmDrawerViewController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
                if (drawerController.openSide == MMDrawerSideLeft) {
                    [weakSelf recursivelyRemoveScrollingToTop:drawerController.centerViewController.view];
                } else {
                    [weakSelf restoreScrollingToTop:drawerController.centerViewController.view];
                }
            }];
            
            return self.mmDrawerViewController;
    }
}

-(BOOL)drawerShouldOpen{
    id viewController = self.centerViewController;
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
- (void)placeButtonInCenterViewController{
    UIViewController *viewController = [self centerViewController];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        if ([nav.viewControllers count] > 0) viewController = (nav.viewControllers)[0];
    }
    
    UINavigationItem *navigationItem = viewController.navigationItem;
    if (!navigationItem.leftBarButtonItem) navigationItem.leftBarButtonItem = (self.drawerImplementation == DrawerImplementationSplitView) ? self.splitViewController.displayModeButtonItem : self.menuBarButtonItem;
}

#pragma mark Drawer Interface
-(UIViewController *)topViewControllerForChannel:(NSDictionary *)channel{
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
    
    UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
    [RUAppearance applyAppearanceToNavigationController:navController];
    vc = navController;
    
    return vc;
}

-(void)setCenterChannel:(NSDictionary *)channel{
    self.currentChannel = channel;
    [RUChannelManager sharedInstance].lastChannel = channel;
    self.centerViewController = [self topViewControllerForChannel:channel];
}

-(UIViewController *)centerViewController{
    switch (self.drawerImplementation) {
        case DrawerImplementationSplitView:
            return self.splitViewController.viewControllers[1];
        case DrawerImplementationSWReveal:
            return self.revealViewController.frontViewController;
        case DrawerImplementationMMDrawer:
            return self.mmDrawerViewController.centerViewController;
    }
}

-(void)setCenterViewController:(UIViewController *)centerViewController{
    switch (self.drawerImplementation) {
        case DrawerImplementationSplitView:
            self.splitViewController.viewControllers = @[self.splitViewController.viewControllers.firstObject, centerViewController];
            break;
        case DrawerImplementationSWReveal:
            [self.revealViewController pushFrontViewController:centerViewController animated:NO];
            break;
        case DrawerImplementationMMDrawer:
            [self.mmDrawerViewController setCenterViewController:centerViewController withCloseAnimation:NO completion:nil];
            break;
    }
    [self placeButtonInCenterViewController];
}

-(void)closeDrawer{
    switch (self.drawerImplementation) {
        case DrawerImplementationSplitView:
            break;
        case DrawerImplementationSWReveal:
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
            break;
        case DrawerImplementationMMDrawer:
            [self.mmDrawerViewController closeDrawerAnimated:YES completion:nil];
            break;
    }
    [self restoreScrollingToTop:self.centerViewController.view];
}

-(void)openDrawer{
    switch (self.drawerImplementation) {
        case DrawerImplementationSplitView:
            break;
        case DrawerImplementationSWReveal:
            [self.revealViewController setFrontViewPosition:FrontViewPositionRight animated:YES];
            break;
        case DrawerImplementationMMDrawer:
            [self.mmDrawerViewController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
            break;
    }
    [self recursivelyRemoveScrollingToTop:self.centerViewController.view];
}

-(void)openDrawerIfNeeded{
    if ([self channelIsSplashChannel:[RUChannelManager sharedInstance].lastChannel]){
        [self openDrawer];
    }
}

-(BOOL)channelIsSplashChannel:(NSDictionary *)channel{
    return [[channel channelView] isEqualToString:@"splash"];
}



#pragma mark Scroll View Scrolling to Top
-(void)recursivelyRemoveScrollingToTop:(UIView *)view{
    if ([view isKindOfClass:[UIScrollView class]]) [self removeScrollingToTop:(UIScrollView *)view];
    for (UIView *subview in view.subviews) {
        [self recursivelyRemoveScrollingToTop:subview];
    }
}

-(void)removeScrollingToTop:(UIScrollView *)scrollView{
    if (scrollView.scrollsToTop){
        [self.managedScrollViews addObject:scrollView];
        scrollView.scrollsToTop = NO;
    }
}

-(void)restoreScrollingToTop:(UIView *)view{
    for (UIScrollView *scrollView in self.managedScrollViews) {
        scrollView.scrollsToTop = YES;
    }
    [self.managedScrollViews removeAllObjects];
}

#pragma mark - Delegation
#pragma mark Split View Delegate
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc{
    self.menuBarButtonItem = barButtonItem;
    [self placeButtonInCenterViewController];
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    
}

#pragma mark Menu Delegate

-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{
    if (![channel isEqualToDictionary:self.currentChannel]) [self setCenterChannel:channel];
    [self closeDrawer];
}


@end
