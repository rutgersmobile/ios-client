//
//  RUPredictionsViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandingTableViewController.h"

@interface RUPredictionsViewController : ExpandingTableViewController <UIActionSheetDelegate>
/**
 *  The predictions view controller is initialized with an item to display.
 *
 *  @param item The item to display, this may be a stop or a route
 *
 *  @return The initialized view controller
 */
-(instancetype)initWithItem:(id)item; //Route or stop
-(instancetype)initWithSerializedItem:(id)item title:(NSString *)title;
@end
