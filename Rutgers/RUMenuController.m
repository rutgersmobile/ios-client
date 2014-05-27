//
//  RURootViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuController.h"
#import "RUDrawerViewController.h"
#import "RUSidePanelController.h"
#import "RUChannelManager.h"

@interface RUMenuController () <RUMenuDelegate, UISplitViewControllerDelegate>
@property NSDictionary *currentChannel;
@property RUSidePanelController *sidePanel;
@property UISplitViewController *splitViewController;
@property UIBarButtonItem *splitViewBarButtonItem;
@property UIPopoverController *popOver;
@end

@implementation RUMenuController

-(UIViewController *)makeMenu{
    RUDrawerViewController * menu = [[RUDrawerViewController alloc] init];
    menu.delegate = self;
    
    UINavigationController *menuNav = [[UINavigationController alloc] initWithRootViewController:menu];
    UIViewController *defaultVC = [[UINavigationController alloc] initWithRootViewController:[self makeDefaultScreen]];
    
  //  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        RUSidePanelController * sidePanel = [[RUSidePanelController alloc] init];
        sidePanel.view.backgroundColor = [UIColor whiteColor];
        // TODO: motd, prefs, launch last used channel
      
        sidePanel.centerPanel = defaultVC;
        sidePanel.leftPanel = menuNav;
        self.sidePanel = sidePanel;
    
        double delayInSeconds = 0.30;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [sidePanel showLeftPanelAnimated:YES];
        });
        
        return sidePanel;
  /*
    } else {
        UISplitViewController *splitView = [[UISplitViewController alloc] init];
        splitView.viewControllers = @[menuNav,defaultVC];
        splitView.delegate = self;
        splitView.presentsWithGesture = NO;
        
        self.splitViewController = splitView;
        return splitView;
    }*/
}
-(void)menu:(RUDrawerViewController *)menu didSelectChannel:(NSDictionary *)channel{
    [self selectionMade];
    if (![channel isEqual:self.currentChannel]) {
        self.currentChannel = channel;
        UIViewController * vc = [[UINavigationController alloc] initWithRootViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:channel]];
        [self updateCenterWithViewController:vc];
        [self setPanelBarButtonItem:self.splitViewBarButtonItem];
        [self.popOver dismissPopoverAnimated:YES];
    }
}
-(void)selectionMade{
    if (self.sidePanel) {
        [self.sidePanel showCenterPanelAnimated:YES];
    }
}
-(void)updateCenterWithViewController:(UIViewController *)viewController{
    if (self.sidePanel) {
        [self.sidePanel setCenterPanel:viewController];
    } else {
        self.splitViewController.viewControllers = @[[self.splitViewController.viewControllers firstObject],viewController];
    }
}
- (UIViewController *)makeDefaultScreen {
    UIViewController * splashViewController = [[UIViewController alloc] init];
    splashViewController.view.backgroundColor = [UIColor whiteColor];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchImage-700"]];
    [splashViewController.view addSubview:imageView];
    imageView.center = splashViewController.view.center;
    return splashViewController;
}
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc{
    self.splitViewBarButtonItem = barButtonItem;
    self.popOver = pc;
    [self setPanelBarButtonItem:barButtonItem];
}
-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    self.splitViewBarButtonItem = nil;
    [self.popOver dismissPopoverAnimated:YES];
    self.popOver = nil;
    [self setPanelBarButtonItem:nil];
}
-(void)setPanelBarButtonItem:(UIBarButtonItem *)button{
     [self.splitViewController.viewControllers[1] topViewController].navigationItem.leftBarButtonItem = button;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
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
