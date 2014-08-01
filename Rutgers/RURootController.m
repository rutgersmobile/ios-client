//
//  RURootViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURootController.h"
#import "RUMenuViewController.h"
//#import "RUSidePanelController.h"
//#import <MSDynamicsDrawerViewController.h>
#import <SWRevealViewController.h>
#import "RUChannelManager.h"
#import "RUUserInfoManager.h"

@interface RURootController () <RUMenuDelegate, UISplitViewControllerDelegate>//, MSDynamicsDrawerViewControllerDelegate>
@property NSDictionary *currentChannel;

//@property (nonatomic) MSDynamicsDrawerViewController *drawerController;
//@property (nonatomic) RUSidePanelController *sidePanel;
@property (nonatomic) SWRevealViewController *containerController;
//@property (nonatomic) UISplitViewController *splitViewController;
//@property (nonatomic) UIPopoverController *popOver;
@end

@implementation RURootController

-(UIViewController *)makeRootViewController{
    RUMenuViewController * menu = [[RUMenuViewController alloc] init];
    menu.delegate = self;
    
    UIViewController *defaultVC = [self makeDefaultScreen];
    
    self.containerController = [[SWRevealViewController alloc] initWithRearViewController:menu frontViewController:nil];
    [self updateCenterWithViewController:defaultVC];
    
    self.containerController.replaceViewAnimationDuration = 0.1;
    self.containerController.toggleAnimationType = SWRevealToggleAnimationTypeEaseOut;
    self.containerController.toggleAnimationDuration = 0.2;
    self.containerController.view.backgroundColor = nil;
    /*
    RUSidePanelController * sidePanel = [[RUSidePanelController alloc] init];
    
    sidePanel.centerPanel = defaultVC;
    sidePanel.leftPanel = menu;
    
    self.sidePanel = sidePanel;*/
    /*
     
    self.drawerController = [[MSDynamicsDrawerViewController alloc] init];
    
    self.drawerController.paneViewSlideOffAnimationEnabled = NO;
    self.drawerController.shouldAlignStatusBarToPaneView = NO;
    self.drawerController.gravityMagnitude = 3.5;
    self.drawerController.elasticity = 0.0;
    self.drawerController.delegate = self;
*/
    /*
   // MSDynamicsDrawerShadowStyler *shadowStyler = [[MSDynamicsDrawerShadowStyler alloc] init];
    MSDynamicsDrawerScaleStyler *scaleStyler = [[MSDynamicsDrawerScaleStyler alloc] init];
    MSDynamicsDrawerFadeStyler *fadeStyler = [[MSDynamicsDrawerFadeStyler alloc] init];
   // MSDynamicsDrawerResizeStyler *resizeStyler = [[MSDynamicsDrawerResizeStyler alloc] init];
    
    //shadowStyler,resizeStyler
    [self.drawerController addStylersFromArray:@[scaleStyler,fadeStyler] forDirection:MSDynamicsDrawerDirectionLeft];
    self.drawerController.paneViewController = defaultVC;
    [self.drawerController setDrawerViewController:menu forDirection:MSDynamicsDrawerDirectionLeft];
*/
    
    return self.containerController;
}

- (void)placeButtonAndGestureRecognizerForLeftPanelInViewController:(UIViewController *)viewControler {
    if ([viewControler isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewControler;
        if ([nav.viewControllers count] > 0) {
            viewControler = [nav.viewControllers objectAtIndex:0];
        }
    }
    if (!viewControler.navigationItem.leftBarButtonItem) {
        viewControler.navigationItem.leftBarButtonItem = [self leftButtonForCenterPanel];
    }
    [viewControler.view addGestureRecognizer:self.containerController.panGestureRecognizer];
}

-(UIBarButtonItem *)leftButtonForCenterPanel{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slider"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];
    return button;
}

/*
-(BOOL)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController shouldBeginPanePan:(UIPanGestureRecognizer *)panGestureRecognizer{
    UIViewController *paneViewController = drawerViewController.paneViewController;
    if ([paneViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)paneViewController;
        if (navController.viewControllers.count > 1) return NO;
    }
    return YES;
}*/

-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{

    if (![channel isEqual:self.currentChannel]) {
        self.currentChannel = channel;
        
        UIViewController * vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [RUAppearance applyAppearanceToNavigationController:navController];
        
        [self updateCenterWithViewController:navController];
    }
    [self closeDrawer];
}


-(void)updateCenterWithViewController:(UIViewController *)viewController{
    [self placeButtonAndGestureRecognizerForLeftPanelInViewController:viewController];
    
  //  [self.sidePanel setCenterPanel:viewController];
    [self.containerController setFrontViewController:viewController];
   // NSLog(@"%@",[self.containerController performSelector:@selector(recursiveDescription)]);
    /*
    [self.drawerController setPaneViewController:viewController animated:YES completion:^{
        
    }];*/
}

-(void)toggleLeftPanel:(id)sender{
    [self.containerController revealToggle:sender];
    // [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void)closeDrawer{
    [self.containerController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    //[self.sidePanel showCenterPanelAnimated:YES];
}

-(void)openDrawer{
    [self.containerController setFrontViewPosition:FrontViewPositionRight animated:YES];
    //[self.sidePanel showLeftPanelAnimated:YES];
}

-(void)openDrawerWide{
    [self openDrawer];
   // [self.sidePanel showLeftPanelAnimated:YES];
}

- (UIViewController *)makeDefaultScreen {
    UIViewController * splashViewController = [[UIViewController alloc] init];
    splashViewController.view.backgroundColor = [UIColor whiteColor];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchImage-700"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [splashViewController.view addSubview:imageView];
    [imageView autoCenterInSuperview];
    
    return splashViewController;
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
