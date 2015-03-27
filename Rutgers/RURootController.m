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

typedef enum : NSUInteger {
    DrawerImplementationSWReveal,
    DrawerImplementationMMDrawer
} DrawerImplementation;

@interface RURootController () <RUMenuDelegate, UINavigationControllerDelegate>
@property (nonatomic) SWRevealViewController *revealViewController;
@property (nonatomic) MMDrawerController *mmDrawerViewController;

@property (nonatomic) RUMenuViewController *menuViewController;
@property (nonatomic) NSHashTable *managedScrollViews;

@property (nonatomic) UIBarButtonItem *menuBarButtonItem;
@property (nonatomic) UIViewController *centerViewController;
@property (nonatomic) DrawerImplementation drawerImplementation;
@property (nonatomic) BOOL drawerShouldOpen;
@end

@implementation RURootController
-(DrawerImplementation)drawerImplementation{
    return DrawerImplementationMMDrawer;
}

#pragma mark initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.managedScrollViews = [NSHashTable weakObjectsHashTable];
        
        UIViewController *centerViewController = [self topViewControllerForChannel:[RUChannelManager sharedInstance].lastChannel];
        _containerViewController = [self makeContainerViewControllerWithCenterViewController:centerViewController leftViewController:self.menuViewController];

        self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(openDrawer)];
        [self placeButtonInCenterViewController];
    }
    return self;
}

-(RUMenuViewController *)menuViewController{
    if (!_menuViewController) {
        _menuViewController = [[RUMenuViewController alloc] init];
        _menuViewController.delegate = self;
    }
    return _menuViewController;
}

-(UIViewController *)makeContainerViewControllerWithCenterViewController:(UIViewController *)centerViewController leftViewController:(UIViewController *)leftViewController{
    
    CGFloat revealWidth = iPad() ? round(270 * IPAD_SCALE) : 270;
    CGFloat revealDisplacement = 55;
    NSTimeInterval animationDuration = 0.24;
    
    switch (self.drawerImplementation) {
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
            
            self.mmDrawerViewController.openDrawerGestureModeMask = MMOpenDrawerGestureModeCustom;
            [self updateDrawerShouldOpen];

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
                if (percentVisible <= 1.0) {
                    drawerController.leftDrawerViewController.view.transform = CGAffineTransformMakeTranslation((percentVisible-1)*revealDisplacement, 0);
                } else {
                    CGAffineTransform translate = CGAffineTransformMakeTranslation((percentVisible-1)*revealDisplacement*2, 0);
                    CGAffineTransform scale = CGAffineTransformMakeScale(percentVisible, 1);
                    drawerController.leftDrawerViewController.view.transform = CGAffineTransformConcat(translate, scale);
                }
            }];
            
            __weak typeof(self) weakSelf = self;
            [self.mmDrawerViewController setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
                if ([touch locationInView:drawerController.view.window].x <= 13.0 && weakSelf.drawerShouldOpen) {
                    return YES;
                }
                return NO;
            }];
            
            return self.mmDrawerViewController;
    }
}

-(void)updateDrawerShouldOpen{
    id viewController = self.centerViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = viewController;
        if ([nav.viewControllers count] > 1) {
            self.drawerShouldOpen = NO;
            return;
        }
        viewController = nav.topViewController;
    }
    if ([viewController isKindOfClass:[TableViewController class]]) {
        self.drawerShouldOpen = ![viewController isSearching];
        return;
    }
    self.drawerShouldOpen = NO;
}

#pragma mark Managing Buttons
- (void)placeButtonInCenterViewController{
    UIViewController *viewController = [self centerViewController];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        if ([nav.viewControllers count] > 0) viewController = [nav.viewControllers objectAtIndex:0];
    }
    
    UINavigationItem *navigationItem = viewController.navigationItem;
    if (!navigationItem.leftBarButtonItem) navigationItem.leftBarButtonItem = self.menuBarButtonItem;
}

#pragma mark Drawer Interface
-(UIViewController *)topViewControllerForChannel:(NSDictionary *)channel{
    UIViewController *vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
    
    if (![[channel channelView] isEqualToString:@"splash"]) {
        UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
        navController.delegate = self;
        [RUAppearance applyAppearanceToNavigationController:navController];
        vc = navController;
    }
    
    return vc;
}
-(void)setCenterChannel:(NSDictionary *)channel{
    self.centerViewController = [self topViewControllerForChannel:channel];
}

-(UIViewController *)centerViewController{
    switch (self.drawerImplementation) {
        case DrawerImplementationSWReveal:
            return self.revealViewController.frontViewController;
        case DrawerImplementationMMDrawer:
            return self.mmDrawerViewController.centerViewController;
    }
}

-(void)setCenterViewController:(UIViewController *)centerViewController{
    switch (self.drawerImplementation) {
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
        case DrawerImplementationSWReveal:
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
            break;
        case DrawerImplementationMMDrawer:
            [self.mmDrawerViewController closeDrawerAnimated:YES completion:nil];
            break;
    }
    [self restoreScrollingToTop:self.centerViewController.view];
}

-(void)openDrawerIfNeeded{
    if ([self channelIsSplashChannel:[RUChannelManager sharedInstance].lastChannel]){
        [self openDrawer];
    }
}

-(BOOL)channelIsSplashChannel:(NSDictionary *)channel{
    return [[channel channelView] isEqualToString:@"splash"];
}

-(void)openDrawer{
    switch (self.drawerImplementation) {
        case DrawerImplementationSWReveal:
            [self.revealViewController setFrontViewPosition:FrontViewPositionRight animated:YES];
            break;
        case DrawerImplementationMMDrawer:
            [self.mmDrawerViewController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
            break;
    }
    [self recursivelyRemoveScrollingToTop:self.centerViewController.view];
}

#pragma mark Scroll View Scrolling to Top
-(void)recursivelyRemoveScrollingToTop:(UIView *)view{
    [self removeScrollingToTop:view];
    for (UIView *subview in view.subviews) {
        [self recursivelyRemoveScrollingToTop:subview];
    }
}

-(void)removeScrollingToTop:(UIView *)view{
    UIScrollView *scrollView = ((UIScrollView *)view);
    if ([scrollView isKindOfClass:[UIScrollView class]] && scrollView.scrollsToTop){
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
-(void)menuDidSelectCurrentChannel:(RUMenuViewController *)menu{
    [self closeDrawer];
}

-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{
    [self setCenterChannel:channel];
    [RUChannelManager sharedInstance].lastChannel = channel;
    [self closeDrawer];
}

#pragma mark Navigation Controller Delegate
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self updateDrawerShouldOpen];
}

@end
