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
    [self applyAppearanceToNavigationBar:[UINavigationBar appearance]];
    [self applyAppearanceToToolbar:[UIToolbar appearance]];
    [self applyAppearanceToTabBar:[UITabBar appearance]];
}

+(void)applyAppearanceToNavigationController:(UINavigationController *)navigationController{
    [self applyAppearanceToNavigationBar:navigationController.navigationBar];
    [self applyAppearanceToToolbar:navigationController.toolbar];
}

+(void)restoreAppearanceToNavigationController:(UINavigationController *)navigationController{
    [self restoreAppearanceToNavigationBar:navigationController.navigationBar];
    [self restoreAppearanceToToolbar:navigationController.toolbar];
}

+(void)applyAppearanceToTabBarController:(UITabBarController *)tabBarController{
    [self applyAppearanceToTabBar:tabBarController.tabBar];
}

+(void)applyAppearanceToTabBar:(UITabBar *)tabBar{
    tabBar.barTintColor = [UIColor grey1Color];
    tabBar.tintColor = [UIColor whiteColor];
}

+(void)applyAppearanceToNavigationBar:(UINavigationBar *)navigationBar{
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.barTintColor = [self modifiedRed];
}

+(void)applyAppearanceToToolbar:(UIToolbar *)toolbar{
    toolbar.tintColor = [UIColor whiteColor];
    toolbar.barTintColor = [self modifiedRed];
}

+(void)restoreAppearanceToNavigationBar:(UINavigationBar *)navigationBar{
    
    navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         nil, NSForegroundColorAttributeName,
                                         nil];
    navigationBar.tintColor = nil;
    navigationBar.barTintColor = nil;
}

+(void)restoreAppearanceToToolbar:(UIToolbar *)toolbar{
    toolbar.tintColor = nil;
    toolbar.barTintColor = nil;
}

+(UIColor *)modifiedRed{
    CGFloat hue, sat, bright, alpha;
    [[UIColor scarletRedColor] getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:1.0 brightness:bright*0.9 alpha:alpha];
}
@end
