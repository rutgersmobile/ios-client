//
//  RURootViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUContainerController.h"

@interface RURootController : NSObject
+(instancetype)sharedInstance;
-(void)openDrawerIfNeeded;
@property (nonatomic) UIViewController <RUContainerController> *containerViewController;
@property (nonatomic) NSDictionary *currentChannel;
@end