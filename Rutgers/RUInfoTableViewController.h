//
//  RUInfoTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZTableViewController.h"

@interface RUInfoTableViewController : EZTableViewController
+(instancetype)componentForChannel:(NSDictionary *)channel;
@end
