//
//  RUPlaceDetailTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@class RUPlace;

@interface RUPlaceDetailViewController : TableViewController
-(id)initWithPlace:(RUPlace *)place;

@end
