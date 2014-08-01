//
//  RULocationManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RULocationManager.h"
#import <MapKit/MapKit.h>

NSString *LocationManagerDidChangeLocationKey = @"LocationManagerDidChangeLocationKey";
NSString *LocationManagerNotificationLocationKey = @"LocationManagerNotificationLocationKey";


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
        self.locationManager.distanceFilter = 15;  // updates whenever we move 15 m
        self.locationManager.activityType = CLActivityTypeFitness; 	// includes any pedestrian activities
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //middle ground between accuracy and power usage, also 100 meters might be worth using but this may be too inaccurate
        self.locationManager.delegate = self;
    }
    return self;
}

/**
 *  Notify the delegates of location updates
 *
 *  @param manager   The shared manager that has updated
 *  @param locations An array of location updates, the most recent of which will be relayed to any observers
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    [self notifyLocationChanged:location];
}

-(void)notifyLocationChanged:(CLLocation *)location{
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationManagerDidChangeLocationKey object:self userInfo:@{LocationManagerNotificationLocationKey : location}];
}

-(CLLocation *)location{
    return self.locationManager.location;
}

- (void)startUpdatingLocation{
    @synchronized(self) {
        if (self.numberOfUpdates == 0){
            [self.locationManager startUpdatingLocation];
        }
        self.numberOfUpdates++;
    }
}

- (void)stopUpdatingLocation{
    @synchronized(self) {
        self.numberOfUpdates--;
        if (!self.numberOfUpdates == 0) {
            [self.locationManager stopUpdatingLocation];
        }
    }
}
@end
