//
//  RUAppearance.m
//  Rutgers
//
//  Created by Open Systems Solutions on 6/2/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUAppearance.h"

@implementation RUAppearance

+(void)applyAppearance{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

+(void)applyAppearanceToNavigationController:(UINavigationController *)navigationController{
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    CGFloat hue, sat, bright, alpha;
    
    [[UIColor rutgersRedColor] getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    
    navigationController.navigationBar.barTintColor = [UIColor colorWithHue:hue saturation:1.0 brightness:bright*0.93 alpha:alpha];
 //   navigationController.navigationBar.translucent = NO;
}

@end
