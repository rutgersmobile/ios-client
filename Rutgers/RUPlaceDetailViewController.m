//
//  RUPlaceDetailTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailViewController.h"
#import "RUPredictionsViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRightDetailRow.h"
#import "RUBusData.h"
#import "RULocationManager.h"
#import <MapKit/MapKit.h>
#import "NSArray+RUBusStop.h"
#import "RUPlace.h"
#import "RUMapsViewController.h"

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
        
        [self.tableView beginUpdates];
        
        if (place.address) {
        
            NSString *addressString = ABCreateStringWithAddressDictionary(place.address, NO);

            EZTableViewRightDetailRow *addressRow = [[EZTableViewRightDetailRow alloc] initWithText:addressString detailText:nil];
            
            addressRow.didSelectRowBlock = ^{
                [self.navigationController pushViewController:[[RUMapsViewController alloc] initWithPlace:place] animated:YES];
            };
            
            [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:@"Address" rows:@[addressRow]]];
        }

        if (place.title || place.campus || place.buildingCode || place.buildingNumber) {
            EZTableViewSection *infoSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Info"];
            if (place.title) {
                EZTableViewRightDetailRow *titleRow = [[EZTableViewRightDetailRow alloc] initWithText:place.title detailText:nil];
                titleRow.shouldHighlight = NO;
                [infoSection addRow:titleRow];
            }
            if (place.campus) {
                EZTableViewRightDetailRow *campusRow = [[EZTableViewRightDetailRow alloc] initWithText:place.campus detailText:@"Campus"];
                campusRow.shouldHighlight = NO;
                [infoSection addRow:campusRow];
            }
            if (place.buildingCode) {
                EZTableViewRightDetailRow *buildingCodeRow = [[EZTableViewRightDetailRow alloc] initWithText:place.buildingCode detailText:@"Building Code"];
                buildingCodeRow.shouldHighlight = NO;
                [infoSection addRow:buildingCodeRow];
            }
            if (place.buildingNumber) {
                EZTableViewRightDetailRow *buildingNumberRow = [[EZTableViewRightDetailRow alloc] initWithText:place.buildingNumber detailText:@"Building Number"];
                buildingNumberRow.shouldHighlight = NO;
                [infoSection addRow:buildingNumberRow];
            }
            [self addSection:infoSection];
        }
        
        
        if (place.location) {
            NSInteger index = [self numberOfSectionsInTableView:self.tableView];
            [[RUBusData sharedInstance] getStopsNearLocation:place.location completion:^(NSArray *results) {
                EZTableViewSection *nearbySection = [[EZTableViewSection alloc] initWithSectionTitle:@"Nearby Active Stops"];
                for (NSArray *stops in results) {
                    EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:[stops title] detailText:nil];
                    row.didSelectRowBlock = ^{
                        [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:stops] animated:YES];
                    };
                    [nearbySection addRow:row];
                }
                [self insertSection:nearbySection atIndex:index];
            }];
        }
        
        NSArray *offices = place.offices;
        if (offices) {
            EZTableViewSection *officeSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Offices"];
            for (NSString *office in offices) {
                EZTableViewRightDetailRow *officeRow = [[EZTableViewRightDetailRow alloc] initWithText:office detailText:nil];
                officeRow.shouldHighlight = NO;
                [officeSection addRow:officeRow];
            }
            [self addSection:officeSection];
        }
        
        NSString *description = place.description;
        if (description) {
            EZTableViewRightDetailRow *descriptionRow = [[EZTableViewRightDetailRow alloc] initWithText:description detailText:nil];
            descriptionRow.shouldHighlight = NO;
            [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:@"Description" rows:@[descriptionRow]]];
        }
        
        [self.tableView endUpdates];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    }
}

-(BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)) return YES;
    return NO;
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath{
    return YES;
}
@end
