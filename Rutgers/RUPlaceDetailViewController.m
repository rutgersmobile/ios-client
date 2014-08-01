//
//  RUPlaceDetailTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailViewController.h"
#import "RUPredictionsViewController.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"
#import "EZTableViewTextRow.h"

#import "RUBusData.h"

#import <MapKit/MapKit.h>
#import "NSArray+RUBusStop.h"
#import "RUPlace.h"
#import "RUMapsViewController.h"
#import "EZTableViewMapsSection.h"

#import <AddressBookUI/AddressBookUI.h>

@interface RUPlaceDetailViewController ()
@property (nonatomic) RUPlace *place;

@end

@implementation RUPlaceDetailViewController

-(id)initWithPlace:(RUPlace *)place{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.place = place;
        self.title = place.title;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSections];
}

-(void)makeSections{
    RUPlace *place = self.place;
    
    if (place.address) {
        
        NSString *addressString = ABCreateStringWithAddressDictionary(place.address, NO);
        EZTableViewTextRow *addressRow = [[EZTableViewTextRow alloc] initWithText:addressString];
        addressRow.shouldHighlight = NO;
        addressRow.shouldCopy = YES;
        [self.dataSource addSection:[[EZDataSourceSection alloc] initWithSectionTitle:@"Address" items:@[addressRow]]];
    }
    
    if (place.address || place.location) {
        EZTableViewMapsSection *mapsSection = [[EZTableViewMapsSection alloc] initWithSectionTitle:@"Maps" place:self.place];
        [self.dataSource addSection:mapsSection];
        UINavigationController *navController = self.navigationController;
        [mapsSection itemAtIndex:0].didSelectRowBlock = ^{
            [navController pushViewController:[[RUMapsViewController alloc] initWithPlace:place] animated:YES];
        };
    }
    
    if (place.title || place.campus || place.buildingCode || place.buildingNumber) {
        EZDataSourceSection *infoSection = [[EZDataSourceSection alloc] initWithSectionTitle:@"Info"];
        if (place.title) {
            EZTableViewTextRow *titleRow = [[EZTableViewTextRow alloc] initWithText:place.title];
            titleRow.shouldHighlight = NO;
            titleRow.shouldCopy = YES;
            [infoSection addItem:titleRow];
        }
        if (place.campus) {
            EZTableViewRightDetailRow *campusRow = [[EZTableViewRightDetailRow alloc] initWithText:place.campus detailText:@"Campus"];
            campusRow.shouldHighlight = NO;
            campusRow.shouldCopy = YES;
            [infoSection addItem:campusRow];
        }
        if (place.buildingCode) {
            EZTableViewRightDetailRow *buildingCodeRow = [[EZTableViewRightDetailRow alloc] initWithText:place.buildingCode detailText:@"Building Code"];
            buildingCodeRow.shouldHighlight = NO;
            buildingCodeRow.shouldCopy = YES;
            [infoSection addItem:buildingCodeRow];
        }
        if (place.buildingNumber) {
            EZTableViewRightDetailRow *buildingNumberRow = [[EZTableViewRightDetailRow alloc] initWithText:place.buildingNumber detailText:@"Building Number"];
            buildingNumberRow.shouldHighlight = NO;
            buildingNumberRow.shouldCopy = YES;
            [infoSection addItem:buildingNumberRow];
        }
        [self.dataSource addSection:infoSection];
    }
    
    if (place.location) {
        NSInteger index = self.dataSource.numberOfSections;
        [[RUBusData sharedInstance] getActiveStopsNearLocation:place.location completion:^(NSArray *results) {
            EZDataSourceSection *nearbySection = [[EZDataSourceSection alloc] initWithSectionTitle:@"Nearby Active Stops"];
            for (NSArray *stops in results) {
                EZTableViewTextRow *row = [[EZTableViewTextRow alloc] initWithText:[stops title]];
                UINavigationController *navController = self.navigationController;
                row.didSelectRowBlock = ^{
                    [navController pushViewController:[[RUPredictionsViewController alloc] initWithItem:stops] animated:YES];
                };
                [nearbySection addItem:row];
            }
            [self.dataSource insertSection:nearbySection atIndex:index];
        }];
    }
    
    NSArray *offices = place.offices;
    if (offices) {
        EZDataSourceSection *officeSection = [[EZDataSourceSection alloc] initWithSectionTitle:@"Offices"];
        for (NSString *office in offices) {
            EZTableViewTextRow *officeRow = [[EZTableViewTextRow alloc] initWithText:office];
            officeRow.shouldHighlight = NO;
            officeRow.shouldCopy = YES;
            [officeSection addItem:officeRow];
        }
        [self.dataSource addSection:officeSection];
    }
    
    NSString *description = place.description;
    if (description) {
        EZTableViewTextRow *descriptionRow = [[EZTableViewTextRow alloc] initWithText:description];
        descriptionRow.shouldHighlight = NO;
        descriptionRow.shouldCopy = YES;
        [self.dataSource addSection:[[EZDataSourceSection alloc] initWithSectionTitle:@"Description" items:@[descriptionRow]]];
    }
}

-(void)dealloc{
    
}

@end
