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
@end
@implementation RULocationManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 25; // whenever we move 25 m
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        self.locationManager.delegate = self;

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
    if (self.delegates.count == 0) {
        self.delegates = [NSSet setWithObject:delegate];
        [self.locationManager startUpdatingLocation];
    } else {
        self.delegates = [self.delegates setByAddingObject:delegate];
        [delegate locationManager:self didUpdateLocation:self.locationManager.location];
    }
}
-(void)removeDelegatesObject:(id<RULocationManagerDelegate>)delegate{
    NSMutableSet *delegates = [self.delegates mutableCopy];
    [delegates removeObject:delegate];
    self.delegates = [delegates copy];
    if (self.delegates.count == 0) {
        [self.locationManager stopUpdatingLocation];
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    for (id <RULocationManagerDelegate> delegate in self.delegates) {
        [delegate locationManager:self didUpdateLocation:location];
    }
}
@end
