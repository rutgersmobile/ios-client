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
@property NSInteger numberOfUpdates;
@end

@implementation RULocationManager
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
 *  Initialize the location manager with our desired settings
 *
 *  @return The initialized location manager
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 10;  // updates whenever we move 10 m
        self.locationManager.activityType = CLActivityTypeFitness; 	// docs say that this includes any pedestrian activities
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //middle ground between accuracy and power usage, 100 meters is probably too inaccurate
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startUpdatingLocation{
    @synchronized(self) {
        if (self.numberOfUpdates == 0) [self _startUpdatingLocation];
        self.numberOfUpdates++;
    }
}

-(void)_startUpdatingLocation{
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation{
    @synchronized(self) {
        self.numberOfUpdates--;
        if (self.numberOfUpdates == 0) [self.locationManager stopUpdatingLocation];
    }
}

/**
 *  Notify the delegates of location updates 
 *
 *  @param manager   The shared manager that has updated
 *  @param locations An array of location updates, the most recent of which will be relayed to any observers
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    if (location) [self notifyLocationChanged:location];
}

-(void)notifyLocationChanged:(CLLocation *)location{
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationManagerDidChangeLocationKey object:self userInfo:@{LocationManagerNotificationLocationKey : location}];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    // the enum falls through to any of the positive status types, to avoid refering to them by their symbol that isnt available in the pre ios 8 sdk
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            break;
        default:
            @synchronized(self) {
                if (self.numberOfUpdates > 0) [self.locationManager startUpdatingLocation];
            }
            break;
    }
}

-(CLLocation *)location{
    return self.locationManager.location;
}
@end
