//
//  RUAppearance.h
//  Rutgers
//
//  Created by Open Systems Solutions on 6/2/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUAppearance : NSObject
+(void)applyAppearance;
+(void)applyAppearanceToNavigationController:(UINavigationController *)navigationController;
+(void)applyAppearanceToTabBarController:(UITabBarController *)tabBarController;
+(void)applyAppearanceToSearchBar:(UISearchBar *)searchBar;

@end
