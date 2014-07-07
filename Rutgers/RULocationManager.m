//
//  RULocationManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RULocationManager.h"
#import <MapKit/MapKit.h>

@interface RULocationManager () <CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property NSMutableSet *delegates;
@property MKDistanceFormatter *distanceFormatter;
@end

@implementation RULocationManager

/**
 *  Initialize the location manager with our desired settings
 *
 *  @return The initialized location manager
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 25;  // updates whenever we move 25 m
        self.locationManager.activityType = CLActivityTypeFitness; 	// includes any pedestrian activities
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //middle ground between accuracy and power usage, also 100 meters might be worth using but this may be too inaccurate
        self.locationManager.delegate = self;
    }
    return self;
}

/**
 *  Shared location manager singleton method
 *
 *  @return The shared location manager
 */
+(RULocationManager *)sharedLocationManager{
    static RULocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[RULocationManager alloc] init];
    });
    return locationManager;
}

/**
 *  Adds a delegate, turning on location updates if needed, otherwise providing the delegate with the current location
 *
 *  @param delegate The delegate to recieve location callbacks
 */
-(void)addDelegatesObject:(id<RULocationManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        [self.delegates addObject:delegate];
        (self.delegates.count == 1) ? [self.locationManager startUpdatingLocation] : [delegate locationManager:self didUpdateLocation:self.locationManager.location];
    }
}

/**
 *  Removes a delegate, turning off location updates if it is the last item removed
 *
 *  @param delegate The delegate to remove
 */
-(void)removeDelegatesObject:(id<RULocationManagerDelegate>)delegate{
    @synchronized(self.delegates) {
        [self.delegates removeObject:delegate];
        if (self.delegates.count == 0) [self.locationManager stopUpdatingLocation];
    }
}

/**
 *  Notify the delegates of location updates
 *
 *  @param manager   The shared manager that has updated
 *  @param locations An array of location updates, the most recent of which will be relayed to the delegates
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    @synchronized(self.delegates) {
        for (id <RULocationManagerDelegate> delegate in self.delegates) {
            [delegate locationManager:self didUpdateLocation:location];
        }
    }
}
@end
