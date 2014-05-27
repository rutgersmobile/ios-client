//
//  RURootViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURootController.h"
#import "RUMenuViewController.h"
#import "RUSidePanelController.h"
#import "RUChannelManager.h"

@interface RURootController () <RUMenuDelegate, UISplitViewControllerDelegate>
@property NSDictionary *currentChannel;
@property RUSidePanelController *sidePanel;
@property UISplitViewController *splitViewController;
@property UIPopoverController *popOver;
@end

@implementation RURootController

-(UIViewController *)makeRootViewController{
    RUMenuViewController * menu = [[RUMenuViewController alloc] init];
    menu.delegate = self;
    
    UINavigationController *menuNav = [[UINavigationController alloc] initWithRootViewController:menu];

    UIViewController *defaultVC = [self makeDefaultScreen];
    
   // if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        RUSidePanelController * sidePanel = [[RUSidePanelController alloc] init];
        sidePanel.view.backgroundColor = [UIColor whiteColor];
        // TODO: motd, prefs, launch last used channel
        
        sidePanel.centerPanel = defaultVC;
        sidePanel.leftPanel = menuNav;

        self.sidePanel = sidePanel;
        
        double delayInSeconds = 0.15;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [sidePanel showLeftPanelAnimated:YES];
        });
        
        return sidePanel;/*
    } else {
        UISplitViewController *splitView = [[UISplitViewController alloc] init];
        splitView.viewControllers = @[menuNav,defaultVC];
        splitView.delegate = self;
        self.splitViewController = splitView;
        return splitView;
    }*/
}
-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{
    [self selectionMade];
    if (![channel isEqual:self.currentChannel]) {
        self.currentChannel = channel;
        UIViewController * vc = [[UINavigationController alloc] initWithRootViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:channel]];
        [self updateCenterWithViewController:vc];
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

    return splashViewController;
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
