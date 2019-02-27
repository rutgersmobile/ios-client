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
-(instancetype)initWithDictionary:(NSDictionary *)dictionary vehicleArray: (NSDictionary*)vehicleArray generatedOn: (NSDate*)date{
    self = [super init];
    if (self)
    {
        _messages = [[NSMutableArray alloc] init];
        _active = NO;
        _stopActive = NO;
        _routeTitle = @"ROUTE TITLE NOT SET";
        _stopTitle = @"TITLE NOT SET";
        _stop_id = dictionary[@"stop_id"];
        NSMutableArray* mutableArrivals = [[NSMutableArray alloc] init];
        
        for (NSDictionary *arrival in dictionary[@"arrivals"]) {
            RUBusArrival* arrivalObj = [[RUBusArrival alloc] initWithDictionary:arrival generatedOn:date];
            for (RUBusVehicle* vehicle in vehicleArray[arrivalObj.route_id]) {
                if ([arrivalObj.vehicle isEqualToString: vehicle.vehicleId]) {
                    arrivalObj.vehicle = vehicle.callName;
                    break;
                }
            }
            [mutableArrivals addObject: arrivalObj];
        }
        [mutableArrivals sortUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate* first = [(RUBusArrival*)a savedDate];
            NSDate* second = [(RUBusArrival*)b savedDate];
            if (first.timeIntervalSinceNow > second.timeIntervalSinceNow) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedAscending;
            }
        }];
        _arrivals = mutableArrivals;
    }
    return self;
}

-(instancetype)initWithArrivalArray:(NSString*)stopId arrivalArray:(NSArray*)arrivalArray generatedOn:(NSDate*)date{
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
@end
