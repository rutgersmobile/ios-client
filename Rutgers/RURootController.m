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
#import "RUUserInfoManager.h"
#import "RUNavigationController.h"
#import "TableViewController_Private.h"

@interface RURootController () <RUMenuDelegate, SWRevealViewControllerDelegate>
@property (nonatomic) SWRevealViewController *revealViewController;
@property (nonatomic) RUMenuViewController *menuViewController;

//@property (nonatomic) UISplitViewController *splitViewController;

@property (nonatomic) NSHashTable *managedScrollViews;

@property (nonatomic) UIBarButtonItem *menuBarButtonItem;
@property (nonatomic) UIViewController *centerViewController;
@end

@implementation RURootController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.managedScrollViews = [NSHashTable weakObjectsHashTable];
    }
    return self;
}
#pragma initialization
-(UIViewController *)containerViewController{
    return self.revealViewController;
}

-(RUMenuViewController *)menuViewController{
    if (!_menuViewController) {
        _menuViewController = [[RUMenuViewController alloc] init];
        _menuViewController.delegate = self;
    }
    return _menuViewController;
}

-(SWRevealViewController *)revealViewController{
    if (!_revealViewController) {
        
        self.revealViewController = [[SWRevealViewController alloc] initWithRearViewController:self.menuViewController frontViewController:nil];
        self.revealViewController.delegate = self;
        
        self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];
        
        self.revealViewController.rearViewRevealWidth = round(iPad() ? 260 * IPAD_SCALE : 260);
        self.revealViewController.rearViewRevealOverdraw = 0;
        self.revealViewController.rearViewRevealDisplacement = 55;
        self.revealViewController.clipsViewsToBounds = YES;
        self.revealViewController.view.backgroundColor = [UIColor clearColor];
        self.revealViewController.frontViewShadowOpacity = 0;
        self.revealViewController.replaceViewAnimationDuration = 0.4;
        self.revealViewController.toggleAnimationDuration = 0.4;
        
        [self.revealViewController panGestureRecognizer];
        [self.revealViewController tapGestureRecognizer];
        
        NSDictionary *lastChannel = [RUChannelManager sharedInstance].lastChannel;
        
        [self setCenterChannel:lastChannel];
    }
    
    return _revealViewController;
}

-(UIViewController *)centerViewController{
    return self.revealViewController.frontViewController;
}

-(void)setCenterViewController:(UIViewController *)centerViewController{
    [self.revealViewController pushFrontViewController:centerViewController animated:NO];
    [self placeButtonInCenterViewController];
}


#pragma managing buttons
- (void)placeButtonInCenterViewController{
    UIViewController *viewController = [self centerViewController];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        if ([nav.viewControllers count] > 0) viewController = [nav.viewControllers objectAtIndex:0];
    }
    
    UINavigationItem *navigationItem = viewController.navigationItem;
    if (!navigationItem.leftBarButtonItem) navigationItem.leftBarButtonItem = self.menuBarButtonItem;
}

#pragma channel selection
-(void)menuDidSelectCurrentChannel:(RUMenuViewController *)menu{
    [self closeDrawer];
}

-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{
    [self setCenterChannel:channel];
    [RUChannelManager sharedInstance].lastChannel = channel;
    [self closeDrawer];
}

-(void)setCenterChannel:(NSDictionary *)channel{
    UIViewController * vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
    
    if (![[channel channelView] isEqualToString:@"splash"]) {
        UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
        
        [RUAppearance applyAppearanceToNavigationController:navController];
        vc = navController;
    }

    self.centerViewController = vc;
}

-(void)toggleLeftPanel:(id)sender{
    [self.revealViewController revealToggle:sender];
}

-(void)closeDrawer{
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

-(void)openDrawerIfNeeded{
    if ([[[RUChannelManager sharedInstance].lastChannel channelView] isEqualToString:@"splash"]) {
        [self openDrawer];
    }
}
-(void)openDrawer{
    [self.revealViewController setFrontViewPosition:FrontViewPositionRight animated:YES];
}
    
#pragma scroll view scrolls to top
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

#pragma split view delegate
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc{
    self.menuBarButtonItem = barButtonItem;
    [self placeButtonInCenterViewController];
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    
}

#pragma reveal view controller

-(BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController{
    id viewController = revealController.frontViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = viewController;
        if ([nav.viewControllers count] > 1) return false;
        viewController = nav.topViewController;
    }
    if ([viewController isKindOfClass:[TableViewController class]]) return ![viewController isSearching];
    return true;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position{
    UIView *frontView = revealController.frontViewController.view;
    if (position == FrontViewPositionRight) {
        [self recursivelyRemoveScrollingToTop:frontView];
        frontView.userInteractionEnabled = NO;
    } else if (position == FrontViewPositionLeft) {
        [self restoreScrollingToTop:frontView];
        frontView.userInteractionEnabled = YES;
    }
}
@end
