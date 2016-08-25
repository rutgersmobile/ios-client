//
//  RUDiningHallDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "SegmentedDataSource.h"
#import "DataTuple.h"

@interface RUDiningHallDataSource : SegmentedDataSource
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithDiningHall:(NSDictionary *)diningHall NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithSerializedDiningHall:(NSString *)serializedDiningHall NS_DESIGNATED_INITIALIZER;

@property (nonatomic) NSDictionary *diningHall;
@end
