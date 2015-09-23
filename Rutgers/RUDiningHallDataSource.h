//
//  RUDiningHallDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "SegmentedDataSource.h"

@interface RUDiningHallDataSource : SegmentedDataSource
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithDiningHall:(NSDictionary *)diningHall NS_DESIGNATED_INITIALIZER;
@end
