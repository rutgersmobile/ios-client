//
//  RUSplashViewController.m
//  Rutgers
//
//  Created by Open Systems Solutions on 9/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSplashViewController.h"

@interface RUSplashViewController ()

@end

@implementation RUSplashViewController
+(id)newWithChannel:(NSDictionary *)channel{
    return [[self alloc] init];
}

-(void)loadView{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"Splash Screen" owner:nil options:nil];
    UIView *splashView = [nibContents lastObject];
    
    [self.view addSubview:splashView];
    [splashView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
}
@end
