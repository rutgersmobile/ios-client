//
//  RUAppearance.m
//  Rutgers
//
//  Created by Open Systems Solutions on 6/2/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUAppearance.h"
#import "UIColor+RutgersColors.h"

@implementation RUAppearance

/*
 Descript : 
    Apply certain style to the component
 
 */

+(void)applyAppearance{
    //global appearance, nothing right now
  
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self applyAppearanceToNavigationBar:[UINavigationBar appearance]];
    [self applyAppearanceToToolbar:[UIToolbar appearance]];
    [self applyAppearanceToTabBar:[UITabBar appearance]];
}

+(void)applyAppearanceToNavigationController:(UINavigationController *)navigationController{
    [self applyAppearanceToNavigationBar:navigationController.navigationBar];
    [self applyAppearanceToToolbar:navigationController.toolbar];
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
    navigationBar.tintColor = [UIColor whiteColor];    navigationBar.barTintColor = [UIColor rutgersBarRedColor];
}

+(void)applyAppearanceToToolbar:(UIToolbar *)toolbar{
    toolbar.tintColor = [UIColor whiteColor];
    toolbar.barTintColor = [UIColor rutgersBarRedColor];
}

+(void)applyAppearanceToSearchBar:(UISearchBar *)searchBar{
  //  searchBar.barTintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
  //  searchBar.tintColor = [UIColor whiteColor];
}
@end
