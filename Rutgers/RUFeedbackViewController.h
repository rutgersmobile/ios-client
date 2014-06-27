//
//  RUFeedbackViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewController.h"

@interface RUFeedbackViewController : EZTableViewController
+(instancetype)componentForChannel:(NSDictionary *)channel;
@end
