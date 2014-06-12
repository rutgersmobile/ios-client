//
//  EZTableViewMapsSection.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewSection.h"
#import <MapKit/MapKit.h>

@interface EZTableViewMapsSection : EZTableViewSection
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle annotation:(id<MKAnnotation>)annotation;
@end
