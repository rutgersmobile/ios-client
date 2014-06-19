//
//  EZTableViewMapsSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewSection.h"
#import <MapKit/MapKit.h>

@class RUPlace;

@interface EZTableViewMapsSection : EZTableViewSection
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle place:(RUPlace *)place;
@end
