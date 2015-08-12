//
//  RUPrediction.m
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import "RUPrediction.h"
#import "RUArrival.h"

@implementation RUPrediction
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _routeTag = dictionary[@"_routeTag"];
        _stopTag = dictionary[@"_stopTag"];
        
        _routeTitle = dictionary[@"_routeTitle"];
        _stopTitle = dictionary[@"_stopTitle"];
        
        NSDictionary *direction = [dictionary[@"direction"] firstObject];
        
        if (direction) {
            _directionTitle = direction[@"_title"];
            NSMutableArray *arrivals = [NSMutableArray array];
            for (NSDictionary *arrival in direction[@"prediction"]) {
                [arrivals addObject:[[RUArrival alloc] initWithDictionary:arrival]];
            }
            _arrivals = arrivals;
        } else {
            _directionTitle = dictionary[@"_dirTitleBecauseNoPredictions"];
        }
    }
    return self;
}

-(BOOL)active{
    return self.arrivals.count > 0;
}
@end
