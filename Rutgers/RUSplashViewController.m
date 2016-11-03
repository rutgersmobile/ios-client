//
//  RUSplashViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 9/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSplashViewController.h"
#import <PureLayout.h>
#import "RUChannelManager.h"

@interface RUSplashViewController ()
@property (nonatomic) UIViewController *childVC;
@end

@implementation RUSplashViewController
+(NSString *)channelHandle{
    return @"splash";
}

+(void)load
{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel
{
    return [[self alloc] init];
}

// if the url the wrong , then we show a notification
- (instancetype)initWithWrongUrl
{
    self = [super init];
    if (self)
    {
        _showWrongUrlAlert = YES;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_showWrongUrlAlert )
    {
        // show the alert to the user that the url was wrong
        [self showAlertView];
    }
}


-(void)showAlertView
{
    [[[UIAlertView alloc] initWithTitle:@" Error Invalid Url " message:@" Given url has a formatting or content error " delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}




-(void)loadView
{
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

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self updateTraitCollectionForSize:size];
}

-(void)updateTraitCollectionForSize:(CGSize)size
{
    if ([self respondsToSelector:@selector(setOverrideTraitCollection:forChildViewController:)])
    {
        [self setOverrideTraitCollection:[UITraitCollection traitCollectionWithHorizontalSizeClass:(size.width > size.height) ? UIUserInterfaceSizeClassRegular : UIUserInterfaceSizeClassCompact] forChildViewController:self.childVC];
    }
}

-(BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return YES;
}
-(BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

@end
