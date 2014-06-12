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
    navigationController.navigationBar.barTintColor = [self modifiedRed];
    
    navigationController.toolbar.tintColor = [UIColor whiteColor];
    navigationController.toolbar.barTintColor = [self modifiedRed];
}

+(UIColor *)modifiedRed{
    CGFloat hue, sat, bright, alpha;
    [[UIColor scarletRedColor] getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:1.0 brightness:bright*0.9 alpha:alpha];
}
@end
