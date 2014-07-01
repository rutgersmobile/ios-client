 //
//  RURecCenterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRightDetailRow.h"

#import "RURecCenterHoursSection.h"
#import "RURecCenterHoursHeaderRow.h"
#import "RURecCenterHoursHeaderTableViewCell.h"

#import "RURecCenterMeetingAreaRow.h"
#import "RURecCenterMeetingAreaTableViewCell.h"

#import "RUPlace.h"
#import "RUMapsViewController.h"

#import <NSString+HTML.h>

@interface RURecCenterViewController ()
@property (nonatomic) RURecCenterHoursSection *hoursSection;
@property (nonatomic) NSDictionary *recCenter;
@end

@implementation RURecCenterViewController
- (instancetype)initWithTitle:(NSString *)title recCenter:(NSDictionary *)recCenter
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        self.recCenter = recCenter;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSections];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerLeftTapped) name:@"RecCenterHeaderLeft" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRightTapped) name:@"RecCenterHeaderRight" object:nil];
}

-(void)makeSections{
    NSDictionary *meetingAreas = self.recCenter[@"meetingareas"];
    if (meetingAreas.count) {
        RURecCenterHoursSection *hoursSection = [[RURecCenterHoursSection alloc] initWithMeetingAreas:meetingAreas];
        [self addSection:hoursSection];
        self.hoursSection = hoursSection;
    }
    
    NSString *address = self.recCenter[@"FacilityAddress"];
    if (address.length) {
        RUPlace *place = [[RUPlace alloc] initWithTitle:self.title addressString:address];
        EZTableViewSection *addressSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Address"];
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:address detailText:nil];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUMapsViewController alloc] initWithPlace:place] animated:YES];
        };
        row.shouldCopy = YES;
        [addressSection addRow:row];
        
        [self addSection:addressSection];
    }
    
    NSString *information = self.recCenter[@"FacilityInformation"];
    if (information.length) {
        EZTableViewSection *informationSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Information Desk"];
        EZTableViewRightDetailRow *infoRow = [[EZTableViewRightDetailRow alloc] initWithText:information detailText:nil];
        infoRow.shouldHighlight = NO;
        infoRow.shouldCopy = YES;
        [informationSection addRow:infoRow];
        [self addSection:informationSection];
    }
    
    NSString *business = self.recCenter[@"FacilityBusiness"];
    if (business.length) {
        EZTableViewSection *buisnessSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Business Office"];
        EZTableViewRightDetailRow *buisnessRow = [[EZTableViewRightDetailRow alloc] initWithText:business detailText:nil];
        buisnessRow.shouldHighlight = NO;
        buisnessRow.shouldCopy = YES;
        [buisnessSection addRow:buisnessRow];
        [self addSection:buisnessSection];
    }
    
    NSString *description = self.recCenter[@"FacilityBody"];
    if (description.length) {
        EZTableViewSection *descriptionSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Description"];
        EZTableViewRightDetailRow *descriptionRow = [[EZTableViewRightDetailRow alloc] initWithText:[description stringByDecodingHTMLEntities] detailText:nil];
        descriptionRow.shouldHighlight = NO;
        descriptionRow.shouldCopy = YES;
        [descriptionSection addRow:descriptionRow];
        [self addSection:descriptionSection];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)headerLeftTapped {
    [self.hoursSection goLeft];
    [self.tableView reloadData];
}

-(void)headerRightTapped {
    [self.hoursSection goRight];
    [self.tableView reloadData];
}
@end
