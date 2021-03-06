//
//  RUMultiStop.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class RUBusStop;


/*
    Class simply holds an array of stops and gives it a name .

 
 */
@interface RUBusMultipleStopsForSingleLocation : NSObject

@property (nonatomic, readonly) NSArray *stops;
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic) BOOL active;
@property (nonatomic, readonly) NSString *agency;

-(void)addStopsObject:(RUBusStop *)object;

@end
