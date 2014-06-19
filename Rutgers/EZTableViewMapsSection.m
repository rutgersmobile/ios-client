//
//  EZTableViewMapsSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewMapsSection.h"
#import "EZTableViewMapsRow.h"

@implementation EZTableViewMapsSection
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle place:(RUPlace *)place{
    self = [super initWithSectionTitle:sectionTitle];
    if (self) {
        [self addRow:[[EZTableViewMapsRow alloc] initWithPlace:place]];
    }
    return self;
}

@end
