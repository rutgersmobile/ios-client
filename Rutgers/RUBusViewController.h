//
//  RUBusViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentProtocol.h"

@interface RUBusViewController : UITableViewController <RUComponentProtocol>
+(instancetype)component;
@end
