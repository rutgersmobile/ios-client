//
//  RUAppDelegate.h
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) RUUserInfoManager *userInfoManager;

@end
