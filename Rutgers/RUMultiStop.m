//
//  RUMultiStop.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMultiStop.h"
#import "RUBusStop.h"
#import "CLLocation+Centroid.h"

@implementation RUMultiStop
-(instancetype)init{
    self = [super init];
    if (self) {
        _stops = @[];
    }
    return self;
}
-(NSString *)title{
    return [[self.stops firstObject] title];
}

-(NSString *)agency{
    return [[self.stops firstObject] agency];
}

-(void)addStopsObject:(RUBusStop *)object{
    _stops = [self.stops arrayByAddingObject:object];
}

-(CLLocation *)location{
    return [CLLocation centroidOfLocations:[self.stops valueForKey:@"location"]];
}
-(NSString *)description{
    return [self.stops description];
}
@end
