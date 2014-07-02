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
#import "EZTableViewSection.h"
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
    [self startNetworkLoad];
}

-(void)startNetworkLoad{
    [super startNetworkLoad];
    [[RUSOCData sharedInstance] getCoursesForSubjectCode:self.code forCurrentConfigurationWithSuccess:^(NSArray *courses) {
        [self networkLoadSucceeded];

        [self.tableView beginUpdates];
        if (self.sections.count) {
            [self removeAllSections];
        }
        [self makeSectionsForResponse:courses];
        [self.tableView endUpdates];
        
    } failure:^{
        [self networkLoadFailed];
    }];
}

-(void)makeSectionsForResponse:(NSArray *)response{
    EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:@"Courses"];
    for (NSDictionary *course in response) {
        RUSOCCourseRow *row = [[RUSOCCourseRow alloc] initWithCourse:course];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUSOCCourseViewController alloc] initWithCourse:course] animated:YES];
        };
        [section addRow:row];
    }
    [self addSection:section];
}
@end
