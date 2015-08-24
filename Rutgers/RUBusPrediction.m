//
//  RUPrediction.m
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import "RUBusPrediction.h"
#import "RUBusArrival.h"

@implementation RUBusPrediction
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        //Fill up fields from the dictionary
        _routeTag = dictionary[@"_routeTag"];
        _stopTag = dictionary[@"_stopTag"];
        
        _routeTitle = dictionary[@"_routeTitle"];
        _stopTitle = dictionary[@"_stopTitle"];
        
        //Check if there is a direction
        NSDictionary *direction = [dictionary[@"direction"] firstObject];
        if (direction) {
            //Get its title
            _directionTitle = direction[@"_title"];
            
            //Parse the arrivals
            NSMutableArray *arrivals = [NSMutableArray array];
            for (NSDictionary *arrival in direction[@"prediction"]) {
                [arrivals addObject:[[RUBusArrival alloc] initWithDictionary:arrival]];
            }
            _arrivals = arrivals;
        } else {
            //Otherwise the direciton title is in this field
            _directionTitle = dictionary[@"_dirTitleBecauseNoPredictions"];
        }
    }
    return self;
}

/**
 *  Whether the prediction is active
 *
 *  @return Yes if there are some number of arrivals, no otherwise
 */
-(BOOL)active{
    return self.arrivals.count > 0;
}
@end
