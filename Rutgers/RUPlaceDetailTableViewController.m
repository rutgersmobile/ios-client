//
//  RUPlaceDetailTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailTableViewController.h"
#import "TTTAddressFormatter.h"
#import "EZTableViewSection.h"
#import "EZTableViewRow.h"

#define INFO_TAGS @[TITLE,CAMPUS,BUILDING_CODE,BUILDING_NUMBER]


const NSString *TITLE = @"title";
const NSString *BUILDING_NUMBER = @"building_number";
const NSString *CAMPUS = @"campus_name";
const NSString *ADDRESS = @"address";
const NSString *OFFICES = @"offices";
const NSString *BUILDING_CODE = @"building_code";
const NSString *DESCRIPTION = @"description";

@interface RUPlaceDetailTableViewController ()
@property (nonatomic) NSDictionary *place;
@end

@implementation RUPlaceDetailTableViewController

-(id)initWithPlace:(NSDictionary *)place{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.place = place;
        self.title = [self stringForTag:@"title"];

        NSDictionary *location = self.place[@"location"];
        
        if ([location isKindOfClass:[NSDictionary class]]) {
            if (![location[@"street"] isEqualToString:@""] || ![location[@"city"] isEqualToString:@""] || ![location[@"state"] isEqualToString:@""]) {
                NSString *address = [[[self class] sharedFormatter] stringFromAddressWithStreet:location[@"street"] locality:location[@"city"] region:location[@"state"] postalCode:location[@"postal_code"] country:location[@"country"]];
                [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:@"Address" rows:@[[[EZTableViewRow alloc] initWithText:address detailText:nil]]]];
            }
        }
        
        if ([self hasInfoSection]) {
            EZTableViewSection *infoSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Info"];
            NSDictionary *detailTexts = @{CAMPUS:@"Campus",BUILDING_CODE:@"Building Code",BUILDING_NUMBER:@"Building Number"};
            for (NSString *tag in INFO_TAGS) {
                NSString *string = [self stringForTag:tag];
                if (string) {
                    [infoSection addRow:[[EZTableViewRow alloc] initWithText:string detailText:detailTexts[tag]]];
                }
            }
            [self addSection:infoSection];
        }
        
        NSArray *offices = self.place[@"offices"];
        if (offices) {
            EZTableViewSection *officeSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Offices"];
            for (NSString *office in offices) {
                [officeSection addRow:[[EZTableViewRow alloc] initWithText:office detailText:nil]];
            }
            [self addSection:officeSection];
        }
        
        NSString *description = [self stringForTag:DESCRIPTION];
        if (description) {
            [self addSection:[[EZTableViewSection alloc] initWithSectionTitle:@"Description" rows:@[[[EZTableViewRow alloc] initWithText:description detailText:nil]]]];
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
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
@end
