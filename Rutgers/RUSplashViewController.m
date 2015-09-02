//
//  RUSplashViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 9/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSplashViewController.h"
#import <PureLayout.h>

@interface RUSplashViewController ()
@property (nonatomic) UIViewController *childVC;
@end

@implementation RUSplashViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] init];
}

-(void)loadView{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"Splash Screen" owner:nil options:nil];
    viewController.view = [nibContents lastObject];
    
    [self.view addSubview:viewController.view];
    [viewController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    self.childVC = viewController;
    [self updateTraitCollectionForSize:self.view.bounds.size];

}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [self updateTraitCollectionForSize:size];
}

-(void)updateTraitCollectionForSize:(CGSize)size{
    [self setOverrideTraitCollection:[UITraitCollection traitCollectionWithHorizontalSizeClass:(size.width > size.height) ? UIUserInterfaceSizeClassRegular : UIUserInterfaceSizeClassCompact] forChildViewController:self.childVC];
}

-(BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return YES;
}
-(BOOL)shouldAutomaticallyForwardRotationMethods{
    return YES;
}

@end
