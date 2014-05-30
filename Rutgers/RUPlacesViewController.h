//
//  RUPlacesTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentProtocol.h"
#import "ALTableViewController.h"

@interface RUPlacesViewController : ALTableViewController <RUComponentProtocol>
+(instancetype)component;

@end
