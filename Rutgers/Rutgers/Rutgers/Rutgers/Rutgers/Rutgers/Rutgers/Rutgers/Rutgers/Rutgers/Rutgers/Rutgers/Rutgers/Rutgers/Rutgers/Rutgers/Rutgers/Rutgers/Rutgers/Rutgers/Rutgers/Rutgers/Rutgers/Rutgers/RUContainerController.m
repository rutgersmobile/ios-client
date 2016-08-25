//
//  RUContainerController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/20/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RUContainerController.h"
#import "RUDefines.h"

#import <SWRevealViewController.h>
#import <MMDrawerController.h>

#define DRAWER_WIDTH (iPad() ? round(270 * IPAD_SCALE) : 270)
#define DRAWER_DISPLACEMENT 55
#define DRAWER_ANIM_DURATION 0.35



@interface UISplitViewController (RUContainer) <RUContainerController>

@end
    

@implementation UISplitViewController (RUContainer)
+(id<RUContainerController>)containerWithContainedViewController:(UIViewController *)containedViewController drawerViewController:(UIViewController *)drawerViewController{
    UISplitViewController *splitVC = [[UISplitViewController alloc] init];
    splitVC.viewControllers = @[drawerViewController,containedViewController];
    splitVC.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    splitVC.maximumPrimaryColumnWidth = DRAWER_WIDTH;
    
    return splitVC;
}
-(UIViewController *)containedViewController{
    return self.viewControllers[1];
}
-(void)setContainedViewController:(UIViewController *)containedViewController{
    self.viewControllers = @[self.viewControllers.firstObject, containedViewController];
}
-(void)openDrawer{
    
}
-(void)closeDrawer{
    
}
-(void)setDrawerShouldOpenBlock:(BOOL(^)())block{
    
}

-(void)toogleDrawer
{
    
}

-(void)setFrontViewControllerInteration:(BOOL) interaction
{
    
}

@end

@interface SWRevealViewController (RUContainer) <RUContainerController>

@end

@implementation SWRevealViewController (RUContainer)
+(id<RUContainerController>)containerWithContainedViewController:(UIViewController *)containedViewController drawerViewController:(UIViewController *)drawerViewController{
    SWRevealViewController *revealVC = [[SWRevealViewController alloc] initWithRearViewController:drawerViewController frontViewController:containedViewController];
    revealVC.rearViewRevealWidth = DRAWER_WIDTH;
    revealVC.rearViewRevealOverdraw = 0;
    revealVC.rearViewRevealDisplacement = DRAWER_DISPLACEMENT;
    revealVC.clipsViewsToBounds = YES;
    revealVC.frontViewShadowOpacity = 0;
    revealVC.replaceViewAnimationDuration = DRAWER_ANIM_DURATION;
    revealVC.toggleAnimationDuration = DRAWER_ANIM_DURATION;
    [revealVC panGestureRecognizer];
    [revealVC tapGestureRecognizer];
    
    return revealVC;
}


// getter and setter for the containedViewController
-(UIViewController *)containedViewController{
    return self.frontViewController;
}
-(void)setContainedViewController:(UIViewController *)containedViewController{
    [self pushFrontViewController:containedViewController animated:NO];
}
-(void)openDrawer{
    [self setFrontViewPosition:FrontViewPositionRight animated:YES];
}
-(void)closeDrawer{
    [self setFrontViewPosition:FrontViewPositionLeft animated:YES];
}
-(void)setDrawerShouldOpenBlock:(BOOL(^)())block{

}

-(void)setFrontViewControllerInteration:(BOOL) interaction
{
    [self.frontViewController.view setUserInteractionEnabled:interaction];
}

-(void)toogleDrawer
{
    [self revealToggleAnimated:YES];
    
    
}

@end

@interface MMDrawerController (RUContainer) <RUContainerController>

@end

@implementation MMDrawerController (RUContainer) // extend class using categories
+(id<RUContainerController>)containerWithContainedViewController:(UIViewController *)containedViewController drawerViewController:(UIViewController *)drawerViewController{
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:containedViewController leftDrawerViewController:drawerViewController];
    
    drawerController.openDrawerGestureModeMask =
    MMOpenDrawerGestureModeBezelPanningCenterView |
    MMOpenDrawerGestureModePanningNavigationBar |
    MMOpenDrawerGestureModeCustom;
    
    drawerController.closeDrawerGestureModeMask =
    MMCloseDrawerGestureModePanningNavigationBar    |
    MMCloseDrawerGestureModePanningCenterView       |
    MMCloseDrawerGestureModeBezelPanningCenterView  |
    MMCloseDrawerGestureModeTapNavigationBar        |
    MMCloseDrawerGestureModeTapCenterView;
    
    drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNone;
    drawerController.maximumLeftDrawerWidth = DRAWER_WIDTH;
    drawerController.animationVelocity = DRAWER_WIDTH/DRAWER_ANIM_DURATION;
    drawerController.showsShadow = NO;
    
    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        drawerController.leftDrawerViewController.view.transform = CGAffineTransformMakeTranslation((percentVisible-1)*DRAWER_DISPLACEMENT, 0);
    }];
    
    return drawerController;
}

-(UIViewController *)containedViewController{
    return self.centerViewController;
}
-(void)setContainedViewController:(UIViewController *)containedViewController{
    [self setCenterViewController:containedViewController withCloseAnimation:NO completion:nil];
}

-(void)openDrawer{
    [self openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)closeDrawer{
    [self closeDrawerAnimated:YES completion:nil];
}

-(void)toogleDrawer
{
    
}


-(void)setFrontViewControllerInteration:(BOOL) interaction
{
    
}




-(void)setDrawerShouldOpenBlock:(BOOL(^)())block{
    [self setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
        UIViewController *centerViewController = drawerController.centerViewController;
        if ([touch.view isDescendantOfView:centerViewController.navigationController.navigationBar]) return YES;
        if ([touch locationInView:centerViewController.view].x > 23.0) return NO;
        return block();
    }];
}
@end

