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
#import "RUBusMultipleStopsForSingleLocation.h"
#import "MiniMapDataSource.h"

#import <AddressBookUI/AddressBookUI.h>
#import <MSWeakTimer.h>

#import "RUPlacesDataLoadingManager.h"
#import "ALTableViewTextCell.h"
#import "RUMapsTableViewCell.h"
#import "ALTableViewRightDetailCell.h"

#define UPDATE_TIME_INTERVAL 60.0

@interface RUPlaceDetailDataSource ()
@property MSWeakTimer *refreshTimer;
@property NearbyActiveStopsDataSource *nearbyActiveStopsDataSource;
@property NSString *serializedPlace;
@end

@implementation RUPlaceDetailDataSource

-(instancetype)initWithPlace:(RUPlace *)place{
    self = [super init];
    if (self) {
        [self setupWithPlace:place];
    }
    return self;
}

-(instancetype)initWithSerializedPlace:(NSString *)serializedPlace{
    self = [super init];
    if (self) {
        self.serializedPlace = serializedPlace;
    }
    return self;
}

-(void)loadContent{
    if (!self.serializedPlace) {
        [super loadContent];
        return;
    }
    
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUPlacesDataLoadingManager sharedInstance] getSerializedPlace:self.serializedPlace withCompletion:^(RUPlace *place, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if (!error && place) {
                [loading updateWithContent:^(typeof(self) me) {
                    [self setupWithPlace:place];
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
    [tableView registerClass:[RUMapsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUMapsTableViewCell class])];
    [tableView registerClass:[ALTableViewRightDetailCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewRightDetailCell class])];
}

-(void)setupWithPlace:(RUPlace *)place{
    if (place.address) {
        NSString *addressString = ABCreateStringWithAddressDictionary(place.address, NO);
        StringDataSource *addressDataSource = [[StringDataSource alloc] initWithItems:@[addressString]];
        addressDataSource.title = @"Address";
        
        [self addDataSource:addressDataSource];
    }
    
    if (place.location) {// || place.address || place.addressString) {
        [self addDataSource:[[MiniMapDataSource alloc] initWithPlace:place]];
    }
    
    if (place.location) {
        NearbyActiveStopsDataSource *nearbyActiveStopsDataSource = [[NearbyActiveStopsDataSource alloc] init];
        nearbyActiveStopsDataSource.location = place.location;
        self.nearbyActiveStopsDataSource = nearbyActiveStopsDataSource;
        [self addDataSource:nearbyActiveStopsDataSource];
        [nearbyActiveStopsDataSource setNeedsLoadContent];
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

-(void)startUpdates{
    if (self.nearbyActiveStopsDataSource) {
        self.refreshTimer = [MSWeakTimer scheduledTimerWithTimeInterval:UPDATE_TIME_INTERVAL target:self.nearbyActiveStopsDataSource selector:@selector(setNeedsLoadContent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [self.nearbyActiveStopsDataSource setNeedsLoadContent];
    }
}

-(void)stopUpdates{
    [self.refreshTimer invalidate];
}
@end
