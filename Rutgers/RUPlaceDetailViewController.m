//
//  RUPlaceDetailTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailViewController.h"
#import "RUPredictionsViewController.h"
#import "TTTAddressFormatter.h"
#import "EZTableViewSection.h"
#import "EZTableViewRow.h"
#import "RUBusData.h"
#import "RULocationManager.h"
#import <MapKit/MapKit.h>
#import "NSArray+RUBusStop.h"

#define INFO_TAGS @[TITLE,CAMPUS,BUILDING_CODE,BUILDING_NUMBER]

const NSString *TITLE = @"title";
const NSString *BUILDING_NUMBER = @"building_number";
const NSString *CAMPUS = @"campus_name";
const NSString *ADDRESS = @"address";
const NSString *OFFICES = @"offices";
const NSString *BUILDING_CODE = @"building_code";
const NSString *DESCRIPTION = @"description";

@interface RUPlaceDetailViewController ()
@property (nonatomic) NSDictionary *place;
@end

@implementation RUPlaceDetailViewController

-(id)initWithPlace:(NSDictionary *)place{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.place = place;
        self.title = [self stringForTag:@"title"];

        NSDictionary *locationDetails = self.place[@"location"];
        CLLocation *location;
        
        if ([locationDetails isKindOfClass:[NSDictionary class]]) {
            if (locationDetails[@"latitude"] && locationDetails[@"longitude"]) {
                location = [[CLLocation alloc] initWithLatitude:[locationDetails[@"latitude"] doubleValue] longitude:[locationDetails[@"longitude"] doubleValue]];
            }
            if (![locationDetails[@"street"] isEqualToString:@""] || ![locationDetails[@"city"] isEqualToString:@""] || ![locationDetails[@"state"] isEqualToString:@""]) {
                NSString *address = [[[self class] sharedFormatter] stringFromAddressWithStreet:locationDetails[@"street"] locality:locationDetails[@"city"] region:locationDetails[@"state"] postalCode:locationDetails[@"postal_code"] country:locationDetails[@"country"]];
                EZTableViewRow *addressRow = [[EZTableViewRow alloc] initWithText:address detailText:nil];
                addressRow.shouldHighlight = NO;
                [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:@"Address" rows:@[addressRow]]];
            }
        }
        
        if ([self hasInfoSection]) {
            EZTableViewSection *infoSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Info"];
            NSDictionary *detailTexts = @{CAMPUS:@"Campus",BUILDING_CODE:@"Building Code",BUILDING_NUMBER:@"Building Number"};
            for (NSString *tag in INFO_TAGS) {
                NSString *string = [self stringForTag:tag];
                if (string) {
                    EZTableViewRow *infoRow = [[EZTableViewRow alloc] initWithText:string detailText:detailTexts[tag]];
                    infoRow.shouldHighlight = NO;
                    [infoSection addRow:infoRow];
                }
            }
            [self addSection:infoSection];
        }
        
        if (location) {
            NSInteger index = [self numberOfSectionsInTableView:self.tableView];
            [[RUBusData sharedInstance] getStopsNearLocation:location completion:^(NSArray *results) {
                EZTableViewSection *nearbySection = [[EZTableViewSection alloc] initWithSectionTitle:@"Nearby Active Stops"];
                for (NSArray *stops in results) {
                   // CLLocationDistance distance = [location distanceFromLocation:[stops location]];
                   // NSString *distanceString = [[RULocationManager sharedLocationManager] formatDistance:distance];
                    EZTableViewRow *row = [[EZTableViewRow alloc] initWithText:[stops title] detailText:nil];
                    row.didSelectRowBlock = ^{
                        [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:stops] animated:YES];
                    };
                    [nearbySection addRow:row];
                }
                [self.tableView beginUpdates];
                [self insertSection:nearbySection atIndex:index];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }];
        }
     
        NSArray *offices = self.place[@"offices"];
        if (offices) {
            EZTableViewSection *officeSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Offices"];
            for (NSString *office in offices) {
                EZTableViewRow *officeRow = [[EZTableViewRow alloc] initWithText:office detailText:nil];
                officeRow.shouldHighlight = NO;
                [officeSection addRow:officeRow];
            }
            [self addSection:officeSection];
        }
        
        NSString *description = [self stringForTag:DESCRIPTION];
        if (description) {
            EZTableViewRow *descriptionRow = [[EZTableViewRow alloc] initWithText:description detailText:nil];
            descriptionRow.shouldHighlight = NO;
            [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:@"Description" rows:@[descriptionRow]]];
        }
    }
    return self;
}
-(BOOL)hasInfoSection{
    for (NSString *tag in INFO_TAGS) {
        if ([self stringForTag:tag]) {
            return true;
        }
    }
    return false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
+(TTTAddressFormatter *)sharedFormatter{
    static TTTAddressFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[TTTAddressFormatter alloc] init];
    });
    return sharedFormatter;
}
-(NSString *)stringForTag:(const NSString *)keypath{
    NSString *string = [self.place valueForKeyPath:[keypath copy]];
    if ([string isKindOfClass:[NSString class]] && ![string isEqualToString:@""]) {
        return string;
    }
    return nil;
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
