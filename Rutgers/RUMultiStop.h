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

@interface RUMultiStop : NSObject
@property (nonatomic) NSArray *stops;
-(NSString *)title;

-(CLLocation *)location;
@property (nonatomic) BOOL active;
-(NSString *)agency;

-(void)addStopsObject:(RUBusStop *)object;
@end
