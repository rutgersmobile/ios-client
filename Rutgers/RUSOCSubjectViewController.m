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
@property NSString *code;
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
    [self.tableView registerClass:[RUSOCCourseCell class] forCellReuseIdentifier:@"RUSOCCourseCell"];
    [[RUSOCData sharedInstance] getCoursesForSubjectCode:self.code inCurrentSemesterWithCompletion:^(NSArray *courses) {
        EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:@"Subjects"];
        for (NSDictionary *course in courses) {
            RUSOCCourseRow *row = [[RUSOCCourseRow alloc] initWithCourse:course];
            row.didSelectRowBlock = ^{
                [self.navigationController pushViewController:[RUSOCCourseViewController alloc] animated:YES];
            };
            [section addRow:row];
        }
        [self addSection:section];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

    }];
}

@end