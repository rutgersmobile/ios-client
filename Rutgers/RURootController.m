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
#import "RUChannelManager.h"
#import "RUUserInfoManager.h"
#import "RUNavigationController.h"

@interface RURootController () <RUMenuDelegate, UISplitViewControllerDelegate, SWRevealViewControllerDelegate>
@property NSDictionary *currentChannel;

@property (nonatomic) SWRevealViewController *containerController;
@end

@implementation RURootController

-(UIViewController *)makeRootViewController{
    RUMenuViewController * menu = [[RUMenuViewController alloc] init];
    menu.delegate = self;
    
    UIViewController *defaultVC = [self makeDefaultScreen];
    
    self.containerController = [[SWRevealViewController alloc] initWithRearViewController:menu frontViewController:nil];
    [self updateCenterWithViewController:defaultVC];
    self.containerController.delegate = self;
    
    self.containerController.view.backgroundColor = nil;
    
    self.containerController.replaceViewAnimationDuration = 0.4;
    self.containerController.toggleAnimationDuration = 0.4;
    //self.containerController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;
    self.containerController.bounceBackOnOverdraw = NO;
    self.containerController.clipsViewsToBounds = YES;
    
    [self.containerController panGestureRecognizer];
    [self.containerController tapGestureRecognizer];

    return self.containerController;
}

- (void)placeButtonInViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        if ([nav.viewControllers count] > 0) {
            viewController = [nav.viewControllers objectAtIndex:0];
        }
    }
    
    if (!viewController.navigationItem.leftBarButtonItem) {
        viewController.navigationItem.leftBarButtonItem = [self leftButtonForCenterPanel];
    }
}

-(UIBarButtonItem *)leftButtonForCenterPanel{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slider"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];
    return button;
}

-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{
    if (![channel isEqual:self.currentChannel]) {
        self.currentChannel = channel;
        
        UIViewController * vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
        UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
        
        [RUAppearance applyAppearanceToNavigationController:navController];
        
        [self updateCenterWithViewController:navController];
    }
    
    [self closeDrawer];
}

-(void)updateCenterWithViewController:(UIViewController *)viewController{
    [self.containerController pushFrontViewController:viewController animated:NO];
    [self placeButtonInViewController:viewController];
}

-(void)toggleLeftPanel:(id)sender{
    [self.containerController revealToggle:sender];
}

-(void)closeDrawer{
    [self.containerController setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

-(void)openDrawer{
    [self.containerController setFrontViewPosition:FrontViewPositionRight animated:YES];
}

- (UIViewController *)makeDefaultScreen {
    UIViewController * splashViewController = [[UIViewController alloc] init];
    splashViewController.view.backgroundColor = [UIColor whiteColor];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DefaultImage"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [splashViewController.view addSubview:imageView];
    [imageView autoCenterInSuperview];
    
    return splashViewController;
}

-(BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController{
    id viewController = revealController.frontViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = viewController;
        if ([nav.viewControllers count] > 1) {
            return false;
        }
    }
    return true;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionRight) {
        revealController.frontViewController.view.userInteractionEnabled = NO;       // Disable the topViewController's interaction
    } else if (position == FrontViewPositionLeft) {
        revealController.frontViewController.view.userInteractionEnabled = YES;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
