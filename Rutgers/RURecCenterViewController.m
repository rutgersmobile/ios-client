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

@interface RURecCenterViewController ()
@property (nonatomic) RURecCenterHoursSection *hoursSection;
@end

@implementation RURecCenterViewController
- (instancetype)initWithTitle:(NSString *)title recCenter:(NSDictionary *)recCenter
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        NSDictionary *meetingAreas = recCenter[@"meetingareas"];
        if (meetingAreas.count) {
            RURecCenterHoursSection *hoursSection = [[RURecCenterHoursSection alloc] initWithMeetingAreas:meetingAreas];
            [self addSection:hoursSection];
            self.hoursSection = hoursSection;
        }
        
        NSString *address = recCenter[@"FacilityAddress"];
        if (address.length) {
            RUPlace *place = [[RUPlace alloc] initWithTitle:title addressString:address];
            EZTableViewSection *addressSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Address"];
            EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:address detailText:nil];
            row.didSelectRowBlock = ^{
                [self.navigationController pushViewController:[[RUMapsViewController alloc] initWithPlace:place] animated:YES];
            };
            [addressSection addRow:row];
            
            [self addSection:addressSection];
        }
        
        NSString *information = recCenter[@"FacilityInformation"];
        if (information.length) {
            EZTableViewSection *informationSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Information Desk"];
            EZTableViewRightDetailRow *infoRow = [[EZTableViewRightDetailRow alloc] initWithText:information detailText:nil];
            infoRow.shouldHighlight = NO;
            [informationSection addRow:infoRow];
            [self addSection:informationSection];
        }
        
        NSString *business = recCenter[@"FacilityBusiness"];
        if (business.length) {
            EZTableViewSection *buisnessSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Business Office"];
            EZTableViewRightDetailRow *buisnessRow = [[EZTableViewRightDetailRow alloc] initWithText:business detailText:nil];
            buisnessRow.shouldHighlight = NO;
            [buisnessSection addRow:buisnessRow];
            [self addSection:buisnessSection];
        }
        
        NSString *description = recCenter[@"FacilityBody"];
        if (description.length) {
            EZTableViewSection *descriptionSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Description"];
            EZTableViewRightDetailRow *descriptionRow = [[EZTableViewRightDetailRow alloc] initWithText:description detailText:nil];
            descriptionRow.shouldHighlight = NO;
            [descriptionSection addRow:descriptionRow];
            [self addSection:descriptionSection];
        }
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[RURecCenterHoursHeaderTableViewCell class] forCellReuseIdentifier:@"RURecCenterHoursHeaderTableViewCell"];
    [self.tableView registerClass:[RURecCenterMeetingAreaTableViewCell class] forCellReuseIdentifier:@"RURecCenterMeetingAreaTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerLeftTapped) name:@"RecCenterHeaderLeft" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRightTapped) name:@"RecCenterHeaderRight" object:nil];
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
