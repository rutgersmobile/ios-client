//
//  NSArray+RUBusStop.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;

@interface NSArray (RUBusStop)
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly) NSString *agency;
@property (nonatomic, readonly) BOOL isArrayOfBusStops;
-(CLLocation *)location;
@end
