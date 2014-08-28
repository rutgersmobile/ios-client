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

@interface RURootController () <RUMenuDelegate, UISplitViewControllerDelegate, SWRevealViewControllerDelegate>
@property (nonatomic) SWRevealViewController *containerController;
@property (nonatomic) UISplitViewController *splitViewController;
@property (nonatomic) NSHashTable *managedScrollViews;
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
-(UIViewController *)makeRootViewController{
    RUMenuViewController *menu = [[RUMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
    menu.delegate = self;
    UIViewController *defaultScreen = [self makeDefaultScreen];
    
    if (iPad()) {
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.viewControllers = @[menu,defaultScreen];
        
        return self.splitViewController;
    } else {
        self.containerController = [[SWRevealViewController alloc] initWithRearViewController:menu frontViewController:nil];
        self.containerController.delegate = self;
        
        [self updateCenterWithViewController:defaultScreen];
        
        self.containerController.view.backgroundColor = nil;
        // self.containerController.frontViewShadowRadius = 4;
        // self.containerController.frontViewShadowOffset = CGSizeMake(0, 0);
        self.containerController.frontViewShadowOpacity = 0;
        
        // self.containerController.draggableBorderWidth = 30.0;
        
        self.containerController.replaceViewAnimationDuration = 0.4;
        self.containerController.toggleAnimationDuration = 0.4;
        
        self.containerController.bounceBackOnOverdraw = NO;
        self.containerController.clipsViewsToBounds = YES;
        
        [self.containerController panGestureRecognizer];
        [self.containerController tapGestureRecognizer];
        
        return self.containerController;
    }
}

- (void)placeButtonInViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        if ([nav.viewControllers count] > 0) viewController = [nav.viewControllers objectAtIndex:0];
    }
    if (!viewController.navigationItem.leftBarButtonItem) viewController.navigationItem.leftBarButtonItem = [self leftButtonForCenterPanel];
}

-(UIBarButtonItem *)leftButtonForCenterPanel{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slider"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftPanel:)];
    return button;
}

-(void)menuDidSelectCurrentChannel:(RUMenuViewController *)menu{
    [self closeDrawer];
}

-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel{
    UIViewController * vc = [[RUChannelManager sharedInstance] viewControllerForChannel:channel];
    UINavigationController *navController = [[RUNavigationController alloc] initWithRootViewController:vc];
    
    [RUAppearance applyAppearanceToNavigationController:navController];
    
    [self updateCenterWithViewController:navController];
    
    [self closeDrawer];
}

-(void)updateCenterWithViewController:(UIViewController *)viewController{
    if (self.splitViewController) {
        NSMutableArray *viewControllers = [self.splitViewController.viewControllers mutableCopy];
        viewControllers[1] = viewController;
        self.splitViewController.viewControllers = viewControllers;
    } else {
        [self.containerController pushFrontViewController:viewController animated:NO];
    }
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

-(UIViewController *)makeDefaultScreen {
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
