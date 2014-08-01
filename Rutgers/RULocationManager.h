//
//  RULocationManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NSString *LocationManagerDidChangeLocationKey;
NSString *LocationManagerNotificationLocationKey;

@class RULocationManager;
@protocol RULocationManagerDelegate <NSObject>
-(void)locationManager:(RULocationManager *)manager didUpdateLocation:(CLLocation *)location;
@end
#define NEARBY_DISTANCE 300


@interface RULocationManager : NSObject
+(RULocationManager *)sharedLocationManager;
-(CLLocation *)location;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
@end
