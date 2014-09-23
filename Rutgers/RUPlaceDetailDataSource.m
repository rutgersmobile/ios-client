//
//  RUPlaceDetailDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailDataSource.h"
#import "NearbyActiveStopsDataSource.h"
#import "StringDataSource.h"
#import "RUPlace.h"
#import "KeyValueDataSource.h"

#import "RUBusDataLoadingManager.h"

#import <MapKit/MapKit.h>
#import "RUMultiStop.h"
#import "RUMapsViewController.h"
#import "EZTableViewMapsSection.h"

#import <AddressBookUI/AddressBookUI.h>


@implementation RUPlaceDetailDataSource

-(id)initWithPlace:(RUPlace *)place{
    self = [super init];
    if (self) {
        
        if (place.address) {
            NSString *addressString = ABCreateStringWithAddressDictionary(place.address, NO);
            StringDataSource *addressDataSource = [[StringDataSource alloc] initWithItems:@[addressString]];
            addressDataSource.title = @"Address";
            
            [self addDataSource:addressDataSource];
        }
        
        if (place.location) {
            EZTableViewMapsSection *mapsSection = [[EZTableViewMapsSection alloc] initWithSectionTitle:@"Maps" place:place];
            [self addDataSource:mapsSection];
        }
        
        
        if (place.location) {
            NearbyActiveStopsDataSource *nearbyActiveStopsDataSource = [[NearbyActiveStopsDataSource alloc] init];
            nearbyActiveStopsDataSource.location = place.location;
            [self addDataSource:nearbyActiveStopsDataSource];
        }
        
        if (place.title || place.campus || place.buildingCode || place.buildingNumber) {
            KeyValueDataSource *infoSection = [[KeyValueDataSource alloc] initWithObject:place];
            infoSection.title = @"Info";
            infoSection.items = @[
                                  @{@"keyPath" : @"title", @"label" : @""},
                                  @{@"keyPath" : @"campus", @"label" : @"Campus"},
                                  @{@"keyPath" : @"buildingCode", @"label" : @"Building Code"},
                                  @{@"keyPath" : @"buildingNumber", @"label" : @"Building Number"},
                                  ];
            
            [self addDataSource:infoSection];
        }
        
        NSArray *offices = place.offices;
        if (offices.count) {
            StringDataSource *officeSection = [[StringDataSource alloc] initWithItems:offices];
            officeSection.title = @"Offices";
            [self addDataSource:officeSection];
        }
        
        NSString *description = place.descriptionString;
        if (description) {
            StringDataSource *descriptionSection = [[StringDataSource alloc] initWithItems:@[description]];
            descriptionSection.title = @"Description";
            [self addDataSource:descriptionSection];
        }
    }
    return self;
}
@end