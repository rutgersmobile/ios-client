//
//  RURootViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RUMenuViewController;

@interface RURootController : NSObject
+(instancetype)sharedInstance;
-(void)openDrawer;
-(void)openDrawerIfNeeded;
@property (nonatomic, readonly) UIViewController *containerViewController;
@property (nonatomic) NSDictionary *currentChannel;
@end