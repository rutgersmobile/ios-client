//
//  RURecCenterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRow.h"

#import "RURecCenterHoursSection.h"
#import "RURecCenterHoursHeaderRow.h"
#import "RURecCenterHoursHeaderTableViewCell.h"

#import "RURecCenterMeetingAreaRow.h"
#import "RURecCenterMeetingAreaTableViewCell.h"

@interface RURecCenterViewController ()
@property RURecCenterHoursSection *hoursSection;
@end
@implementation RURecCenterViewController
- (instancetype)initWithRecCenter:(NSDictionary *)recCenter
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        NSDictionary *meetingAreas = recCenter[@"meetingareas"];
        if (meetingAreas.count) {
            RURecCenterHoursSection *hoursSection = [[RURecCenterHoursSection alloc] initWithMeetingAreas:meetingAreas];
            [self addSection:hoursSection];
            self.hoursSection = hoursSection;
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
-(void)headerLeftTapped {
    [self.hoursSection goLeft];
    [self.tableView reloadData];
}
-(void)headerRightTapped {
    [self.hoursSection goRight];
    [self.tableView reloadData];
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
@end
