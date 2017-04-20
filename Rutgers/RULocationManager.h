//
//  RULocationManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define LocationManagerDidChangeLocationKey @"LocationManagerDidChangeLocationKey"
#define LocationManagerNotificationLocationKey @"LocationManagerNotificationLocationKey"

#define NEARBY_DISTANCE 300

@interface RULocationManager : NSObject
+(RULocationManager *)sharedLocationManager;
@property (nonatomic, readonly) CLLocation *location;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
@end

