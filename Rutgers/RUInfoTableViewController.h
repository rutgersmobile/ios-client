//
//  RUInfoTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentProtocol.h"

@interface RUInfoTableViewController : UITableViewController <RUComponentProtocol>
+(instancetype)component;
@end
