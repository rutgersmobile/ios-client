//
//  RUSOCSubjectViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSubjectViewController.h"
#import "RUSOCViewController.h"
#import "RUSOCData.h"
#import "RUSOCCourseRow.h"
#import "RUSOCCourseCell.h"
#import "EZDataSource.h"
#import "RUSOCCourseViewController.h"

@interface RUSOCSubjectViewController ()
@property (nonatomic) NSString *code;
@end

@implementation RUSOCSubjectViewController
-(id)initWithSubject:(NSString *)subject code:(NSString *)code{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = subject;
        self.code = code;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self enableSearch];
    [self setupContentLoadingStateMachine];
}

-(void)loadNetworkData{
    [[RUSOCData sharedInstance] getCoursesForSubjectCode:self.code withSuccess:^(NSArray *courses) {
        [self.contentLoadingStateMachine networkLoadSuccessful];
        
        [self.tableView beginUpdates];
        [self.dataSource removeAllSections];
        [self makeSectionsForResponse:courses];
        [self.tableView endUpdates];
        
    } failure:^{
        [self.contentLoadingStateMachine networkLoadFailedWithNoData];
    }];
}

-(void)makeSectionsForResponse:(NSArray *)response{
    EZDataSourceSection *section = [[EZDataSourceSection alloc] initWithSectionTitle:@"Courses"];
    for (NSDictionary *course in response) {    
        RUSOCCourseRow *row = [[RUSOCCourseRow alloc] initWithCourse:course];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUSOCCourseViewController alloc] initWithCourse:course] animated:YES];
        };
        [section addItem:row];
    }
    [self.dataSource addSection:section];
}
@end
