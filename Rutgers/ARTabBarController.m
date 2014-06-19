//
//  ARTabBarController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ARTabBarController.h"
#import "RUMenuViewController.h"

@interface ARTabBarController () <UITabBarDelegate>
@property (nonatomic) UIView *contentView;
@property (nonatomic) UITabBar *tabBar;
@property (nonatomic) NSLayoutConstraint *tabBarBottomConstraint;


@property (nonatomic) NSDictionary *currentChannel;
@property (nonatomic) NSMutableArray *channelStack;

@property (nonatomic) UIViewController *currentViewController;
@property (nonatomic) NSMutableDictionary *viewControllers;
@property (nonatomic) UIViewController *menuViewController;

@property (nonatomic) NSMutableArray *tabBarItems;
@end

@implementation ARTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.contentView = [UIView newAutoLayoutView];
    [self.view addSubview:self.contentView];
    self.tabBar = [UITabBar newAutoLayoutView];
    self.tabBar.delegate = self;
    self.tabBar.barStyle = UIBarStyleBlack;
    
    [self.view addSubview:self.tabBar];
    
    [self.contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.contentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.tabBar];
    
    [self.tabBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.tabBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    self.tabBarBottomConstraint = [self.tabBar autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];

    self.menuViewController = [[RUMenuViewController alloc] init];
    [self.tabBar setItems:@[self.menuViewController.tabBarItem] animated:YES];
    [self displayViewController:self.menuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayChannel:(NSDictionary *)channel{
    
}

-(void)displayViewController:(UIViewController *)viewController{
    if (self.currentViewController) {
        [viewController willMoveToParentViewController:nil];  // 1
        [viewController.view removeFromSuperview];            // 2
        [viewController removeFromParentViewController];      // 3
    }
    [self addChildViewController:viewController];                 // 1
    [self.contentView addSubview:viewController.view];
    [viewController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [viewController didMoveToParentViewController:self];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
}

@end
