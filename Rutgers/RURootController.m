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
#import "RUUserInfoManager.h"

@interface RURootController () <RUMenuDelegate, UISplitViewControllerDelegate>
@property NSDictionary *currentChannel;
@property (nonatomic) RUSidePanelController *sidePanel;
@property (nonatomic) UISplitViewController *splitViewController;
@property (nonatomic) UIPopoverController *popOver;
@end

@implementation RURootController

-(UIViewController *)makeRootViewController{
    RUMenuViewController * menu = [[RUMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
    menu.delegate = self;
    
    UINavigationController *menuNav = [[UINavigationController alloc] initWithRootViewController:menu];
    
    UIViewController *defaultVC = [self makeDefaultScreen];
    
    RUSidePanelController * sidePanel = [[RUSidePanelController alloc] init];
    sidePanel.view.backgroundColor = [UIColor whiteColor];
    // TODO: motd, prefs, launch last used channel
    
    sidePanel.centerPanel = defaultVC;
    sidePanel.leftPanel = menuNav;
    
    self.sidePanel = sidePanel;
    
    void(^openPanel)() = ^{
        double delayInSeconds = 0.15;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [sidePanel showLeftPanelAnimated:YES];
        });
    };
    openPanel();
/*
    RUUserInfoManager *infoManager = [RUUserInfoManager sharedInstance];
    if (!infoManager.hasUserInformation) {
        [infoManager getUserInformationCompletion:openPanel];
    } else {
    }*/
    return sidePanel;
    // if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    /*
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
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [splashViewController.view addSubview:imageView];
    [imageView autoCenterInSuperview];

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
