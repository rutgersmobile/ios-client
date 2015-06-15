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
#import "DataSource_Private.h"

@implementation RUSOCSubjectDataSource
-(instancetype)initWithSubjectCode:(NSString *)subjectCode{
    self = [super init];
    if (self) {
        self.subjectCode = subjectCode;
        self.title = @"Courses";
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUSOCDataLoadingManager sharedInstance] getCoursesForSubjectCode:self.subjectCode completion:^(NSArray *courses, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.items = courses;
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSOCCourseCell class] forCellReuseIdentifier:NSStringFromClass([RUSOCCourseCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUSOCCourseCell class]);
}

-(void)configureCell:(RUSOCCourseCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCCourseRow *row = [self itemAtIndexPath:indexPath];
    
    cell.titleLabel.text = row.titleText;
    cell.creditsLabel.text = row.creditsText;
    cell.sectionsLabel.text = row.sectionText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
@end
