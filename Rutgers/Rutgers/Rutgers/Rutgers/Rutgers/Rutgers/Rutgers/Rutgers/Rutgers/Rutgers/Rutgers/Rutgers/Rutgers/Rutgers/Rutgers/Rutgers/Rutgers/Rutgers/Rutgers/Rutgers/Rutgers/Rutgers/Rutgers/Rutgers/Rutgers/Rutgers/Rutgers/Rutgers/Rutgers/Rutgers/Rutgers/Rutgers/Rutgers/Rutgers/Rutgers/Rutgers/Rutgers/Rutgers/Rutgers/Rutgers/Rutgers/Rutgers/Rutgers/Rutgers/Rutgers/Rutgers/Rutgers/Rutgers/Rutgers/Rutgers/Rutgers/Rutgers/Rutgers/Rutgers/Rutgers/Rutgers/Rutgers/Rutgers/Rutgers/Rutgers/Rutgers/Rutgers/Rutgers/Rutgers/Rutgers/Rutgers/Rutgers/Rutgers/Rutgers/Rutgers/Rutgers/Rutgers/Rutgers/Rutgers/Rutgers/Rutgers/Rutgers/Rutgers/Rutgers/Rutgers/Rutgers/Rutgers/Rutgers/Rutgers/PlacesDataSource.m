//
//  PlaceDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "PlacesDataSource.h"
#import "NearbyPlacesDataSource.h"
#import "RecentPlacesDataSource.h"

@implementation PlacesDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addDataSource:[[NearbyPlacesDataSource alloc] init]];
        [self addDataSource:[[RecentPlacesDataSource alloc] init]];
    }
    return self;
}
@end
