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
    RUMenuViewController * menu = [[RUMenuViewController alloc] init];
    menu.delegate = self;
    
    UIViewController *defaultVC = [self makeDefaultScreen];
    
    RUSidePanelController * sidePanel = [[RUSidePanelController alloc] init];
    sidePanel.view.backgroundColor = [UIColor whiteColor];
    // TODO: motd, prefs, launch last used channel
    
    sidePanel.centerPanel = defaultVC;
    sidePanel.leftPanel = menu;
    
    self.sidePanel = sidePanel;

    return sidePanel;
}

-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self closeDrawer];
        if (![channel isEqual:self.currentChannel]) {
            self.currentChannel = channel;
            
            UIViewController * vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
            
            [RUAppearance applyAppearanceToNavigationController:navController];
            
            [self updateCenterWithViewController:navController];
        }
    });
}


-(void)updateCenterWithViewController:(UIViewController *)viewController{
    if (self.sidePanel) {
        [self.sidePanel setCenterPanel:viewController];
    } else {
        self.splitViewController.viewControllers = @[[self.splitViewController.viewControllers firstObject],viewController];
    }
}

-(void)closeDrawer{
    if (self.sidePanel) {
        [self.sidePanel showCenterPanelAnimated:YES];
    }
}

-(void)openDrawer{
    [self.sidePanel showLeftPanelAnimated:YES];
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
