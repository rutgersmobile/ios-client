//
//  RUBusRoute.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUBusRoute : NSObject
-(id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *tag;
@property (nonatomic) NSArray *stops;
@property (nonatomic) BOOL active;
@property (nonatomic) NSArray *directions;
@property (nonatomic) NSSet *activeStops;
@end
