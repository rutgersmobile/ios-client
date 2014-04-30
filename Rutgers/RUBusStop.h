//
//  RUBusStop.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUBusStop : NSObject
-(id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic) NSString *tag;
@property (nonatomic) NSString *title;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSInteger stopId;
@property (nonatomic) NSArray *routes;
-(NSArray *)activeRoutes;
@property (nonatomic) BOOL active;

@end
