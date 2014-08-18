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
-(id)init{
    self = [super init];
    if (self) {
        self.stops = [NSArray array];
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
    self.stops = [self.stops arrayByAddingObject:object];
}

-(CLLocation *)location{
    return [CLLocation centroidOfLocations:[self.stops valueForKey:@"location"]];
}

@end
