//
//  RULocationManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RULocationManager.h"
@interface RULocationManager () <CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property NSMutableSet *delegates;
@end
@implementation RULocationManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 25; // whenever we move 25 m
        self.locationManager.activityType = CLActivityTypeFitness;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
        self.delegates = [NSMutableSet set];
    }
    return self;
}
+(RULocationManager *)sharedLocationManager{
    static RULocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[RULocationManager alloc] init];
    });
    return locationManager;
}

-(void)addDelegatesObject:(id<RULocationManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        if (self.delegates.count == 0) {
            [self.delegates addObject:delegate];
            [self.locationManager startUpdatingLocation];
        } else {
            [self.delegates addObject:delegate];
            [delegate locationManager:self didUpdateLocation:self.locationManager.location];
        }
    }
}

-(void)removeDelegatesObject:(id<RULocationManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        [self.delegates removeObject:delegate];
        if (self.delegates.count == 0) {
            [self.locationManager stopUpdatingLocation];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    @synchronized(self.delegates) {
        for (id <RULocationManagerDelegate> delegate in self.delegates) {
            [delegate locationManager:self didUpdateLocation:location];
        }
    }
}
@end
