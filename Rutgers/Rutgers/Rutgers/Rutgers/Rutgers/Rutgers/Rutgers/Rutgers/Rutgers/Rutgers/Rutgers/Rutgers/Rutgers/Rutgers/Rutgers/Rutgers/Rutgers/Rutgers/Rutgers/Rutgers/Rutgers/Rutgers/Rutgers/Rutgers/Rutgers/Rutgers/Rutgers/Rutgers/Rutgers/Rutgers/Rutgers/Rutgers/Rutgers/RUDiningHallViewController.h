//
//  RUDiningHallViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentedTableViewController.h"

@interface RUDiningHallViewController : SegmentedTableViewController
-(instancetype)initWithDiningHall:(NSDictionary *)diningHall;
-(instancetype)initWithSerializedDiningHall:(NSString *)serializedDiningHall title:(NSString *)title;
@end
