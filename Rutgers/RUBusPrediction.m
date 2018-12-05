//
//  RUPrediction.m
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import "RUBusPrediction.h"
#import "RUBusArrival.h"
#import "RUDefines.h"

@implementation RUBusPrediction
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self)
    {
        _messages = [[NSMutableArray alloc] init];
        _active = YES;
        _tempActive = YES;
        _routeTitle = @"ROUTE TITLE NOT SET";
        _stopTitle = @"TITLE NOT SET";
        _stop_id = dictionary[@"stop_id"];
        NSMutableArray* mutableArrivals = [[NSMutableArray alloc] init];
        
        for (NSDictionary *arrival in dictionary[@"arrivals"]) {
            [mutableArrivals addObject:[[RUBusArrival alloc] initWithDictionary:arrival]];
        }
        [mutableArrivals sortUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate* first = [(RUBusArrival*)a savedDate];
            NSDate* second = [(RUBusArrival*)b savedDate];
            return [first compare:second];
        }];
        _arrivals = mutableArrivals;
    }
    return self;
}

-(instancetype)initWithArrivalArray:(NSString*)stopId arrivalArray:(NSArray*)arrivalArray {
    self = [super init];
    if (self) {
        _messages = [[NSMutableArray alloc] init];
        _active = YES;
        _routeTitle = @"ROUTE TITLE NOT SET";
        _stopTitle = @"TITLE NOT SET";
        _stop_id = stopId;
        NSMutableArray* mutableCopy = [[NSMutableArray alloc] initWithArray:arrivalArray];
        [mutableCopy sortUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate* first = [(RUBusArrival*)a savedDate];
            NSDate* second = [(RUBusArrival*)b savedDate];
            return [first compare:second];
        }];
        _arrivals = mutableCopy;
    }
    return self;
}

/**
 *  Whether the prediction is active
 *
 *  @return Yes if there are some number of arrivals, no otherwise
 */
-(BOOL)active
{
    return self.arrivals.count > 0;
}
@end
