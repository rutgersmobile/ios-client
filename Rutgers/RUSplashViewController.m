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
-(void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"Splash Screen" owner:nil options:nil];
    UIView *splashView = [nibContents lastObject];
    
    [self.view addSubview:splashView];
    [splashView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
}
@end
