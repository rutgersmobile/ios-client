//
//  BusDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "SegmentedDataSource.h"

@interface RUBusDataSource : SegmentedDataSource
-(void)startUpdates;
-(void)stopUpdates;

@end
