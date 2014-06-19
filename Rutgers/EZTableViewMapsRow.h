//
//  EZTableViewMapsRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewAbstractRow.h"
#import <MapKit/MapKit.h> 
@class RUPlace;

@interface EZTableViewMapsRow : EZTableViewAbstractRow
-(instancetype)initWithPlace:(RUPlace *)place;

@end
