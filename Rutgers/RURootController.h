//
//  RURootViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RUMenuViewController;

@protocol RUMenuDelegate <NSObject>
@required
-(void)menu:(RUMenuViewController *)menu didSelectChannel:(NSDictionary *)channel;
@end

@interface RURootController : NSObject
-(UIViewController *)makeRootViewController;
@end