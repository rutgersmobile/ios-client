//
//  RUPredictionsDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewDataSource.h"

/*
    <q> Seems to be used for displaying the bus predictions beneath the route ?
 */

@interface RUPredictionsDataSource : ExpandingTableViewDataSource <UIGestureRecognizerDelegate>
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithItem:(id)item NS_DESIGNATED_INITIALIZER;

-(void)updateSectionsForResponse:(NSArray *)response;


@property id item;

@end
