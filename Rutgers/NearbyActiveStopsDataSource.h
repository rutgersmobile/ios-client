//
//  NearbyActiveStopsDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BusBasicDataSource.h"
#import <MapKit/MapKit.h>

@interface NearbyActiveStopsDataSource : BusBasicDataSource
@property (nonatomic) CLLocation *location;
@end
