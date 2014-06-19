//
//  MKTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewAbstractCell.h"
#import <MapKit/MapKit.h>
#import "RUMapsViewController.h"
@class RUPlace;

@interface RUMapsTableViewCell : ALTableViewAbstractCell
@property (nonatomic) RUPlace *place;

@end
