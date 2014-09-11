 //
//  RURecCenterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterViewController.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"
#import "EZTableViewTextRow.h"

#import "RURecCenterHoursSection.h"
#import "RURecCenterHoursHeaderRow.h"
#import "RURecCenterHoursHeaderTableViewCell.h"

#import "RURecCenterMeetingAreaRow.h"
#import "RURecCenterMeetingAreaTableViewCell.h"

#import "RUPlace.h"
#import "RUMapsViewController.h"

#import <NSString+HTML.h>
#import "NSAttributedString+FromHTML.h"

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
}

-(void)dealloc{
    
}

-(void)makeSections{
    NSDictionary *meetingAreas = self.recCenter[@"meetingareas"];
    if (meetingAreas.count) {
        RURecCenterHoursSection *hoursSection = [[RURecCenterHoursSection alloc] initWithMeetingAreas:meetingAreas];
        [self.dataSource addDataSource:hoursSection];
        self.hoursSection = hoursSection;
    }
    
    NSString *address = self.recCenter[@"FacilityAddress"];
    if (address.length) {
        RUPlace *place = [[RUPlace alloc] initWithTitle:self.title addressString:address];
        EZDataSourceSection *addressSection = [[EZDataSourceSection alloc] initWithSectionTitle:@"Address"];
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:address detailText:nil];
        __weak typeof(self) weakSelf = self;
        row.didSelectRowBlock = ^{
            [weakSelf.navigationController pushViewController:[[RUMapsViewController alloc] initWithPlace:place] animated:YES];
        };
        row.shouldCopy = YES;
        [addressSection addItem:row];
        
        [self.dataSource addDataSource:addressSection];
    }
    
    NSString *information = self.recCenter[@"FacilityInformation"];
    if (information.length) {
        EZDataSourceSection *informationSection = [[EZDataSourceSection alloc] initWithSectionTitle:@"Information Desk"];
        EZTableViewRightDetailRow *infoRow = [[EZTableViewRightDetailRow alloc] initWithText:information detailText:nil];
        infoRow.shouldHighlight = NO;
        infoRow.shouldCopy = YES;
        [informationSection addItem:infoRow];
        [self.dataSource addDataSource:informationSection];
    }
    
    NSString *business = self.recCenter[@"FacilityBusiness"];
    if (business.length) {
        EZDataSourceSection *buisnessSection = [[EZDataSourceSection alloc] initWithSectionTitle:@"Business Office"];
        EZTableViewRightDetailRow *buisnessRow = [[EZTableViewRightDetailRow alloc] initWithText:business detailText:nil];
        buisnessRow.shouldHighlight = NO;
        buisnessRow.shouldCopy = YES;
        [buisnessSection addItem:buisnessRow];
        [self.dataSource addDataSource:buisnessSection];
    }
    
    NSString *description = [[self.recCenter[@"FacilityBody"] stringByDecodingHTMLEntities] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (description.length) {
        EZDataSourceSection *descriptionSection = [[EZDataSourceSection alloc] initWithSectionTitle:@"Description"];
        if (!BETA) {
            EZTableViewRightDetailRow *descriptionRow = [[EZTableViewRightDetailRow alloc] initWithText:description detailText:nil];
            descriptionRow.shouldHighlight = NO;
            descriptionRow.shouldCopy = YES;
            [descriptionSection addItem:descriptionRow];
        } else {
            NSAttributedString *string = [NSAttributedString attributedStringFromHTMLString:description preferedTextStyle:UIFontTextStyleBody];
            EZTableViewTextRow *descriptionRow = [[EZTableViewTextRow alloc] initWithAttributedText:string];
            descriptionRow.shouldHighlight = NO;
            descriptionRow.shouldCopy = YES;
            [descriptionSection addItem:descriptionRow];
        }
        [self.dataSource addDataSource:descriptionSection];
    }
}


@end
