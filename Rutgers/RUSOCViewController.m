//
//  RUSOCViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCViewController.h"
#import "RUSOCData.h"
#import "EZTableViewSection.h"
#import "EZTableViewRightDetailRow.h"
#import "ALTableViewRightDetailCell.h"
#import "RUSOCSubjectViewController.h"

@interface RUSOCViewController () <UISearchDisplayDelegate>
@end

@implementation RUSOCViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUSOCViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self enableSearch];
    [self startNetworkLoad];
       // Do any additional setup after loading the view.
}
-(void)startNetworkLoad{
    [super startNetworkLoad];
    [[RUSOCData sharedInstance] getSubjectsForCurrentConfigurationWithSuccess:^(NSArray *subjects) {
        [self networkLoadSucceeded];
        if (self.sections.count) {
            [self removeAllSections];
        }
        [self makeSectionsForResponse:subjects];
    } failure:^{
        [self networkLoadFailed];
    }];
}

-(void)makeSectionsForResponse:(NSArray *)response{
    EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:@"Subjects"];
    for (NSDictionary *subject in response) {
        NSString *subjectTitle = [NSString stringWithFormat:@"%@ (%@)",[subject[@"description"] capitalizedString],subject[@"code"]];
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:subjectTitle];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUSOCSubjectViewController alloc] initWithSubject:subjectTitle code:subject[@"code"]] animated:YES];
        };
        [section addRow:row];
    }
    [self addSection:section];
}


@end
