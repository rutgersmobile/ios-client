//
//  RUBusStop.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import <MapKit/MapKit.h>

@interface RUBusStop : NSObject
-(id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic) NSString *tag;
@property (nonatomic) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSInteger stopId;
@property (nonatomic, getter = inRoutes) NSArray *routes;
@property (nonatomic, readonly) NSSet *activeRoutes;
@property (nonatomic) BOOL active;

@end
