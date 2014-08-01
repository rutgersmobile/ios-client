//
//  RUSOCSubjectDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSubjectDataSource.h"
#import "RUSOCCourseRow.h"
#import "RUSOCDataLoadingManager.h"
#import "RUSOCCourseCell.h"



@implementation RUSOCSubjectDataSource
-(id)initWithSubjectCode:(NSString *)subjectCode{
    self = [super init];
    if (self) {
        self.subjectCode = subjectCode;
        self.title = @"Courses";
    }
    return self;
}

-(void)loadContent{
    [[RUSOCDataLoadingManager sharedInstance] getCoursesForSubjectCode:self.subjectCode withSuccess:^(NSArray *courses) {
        [self makeSectionsForResponse:courses];
    } failure:^{
    }];
}

-(void)makeSectionsForResponse:(NSArray *)response{
    NSMutableArray *parsedItems = [NSMutableArray array];
    for (NSDictionary *course in response) {
        RUSOCCourseRow *row = [[RUSOCCourseRow alloc] initWithCourse:course];
        [parsedItems addObject:row];
    }
    self.items = parsedItems;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSOCCourseCell class] forCellReuseIdentifier:NSStringFromClass([RUSOCCourseCell class])];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RUSOCCourseCell class])];
    RUSOCCourseRow *row = [self itemAtIndexPath:indexPath];
    
    cell.titleLabel.text = row.titleText;
    cell.creditsLabel.text = row.creditsText;
    cell.sectionsLabel.text = row.sectionText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}
@end
