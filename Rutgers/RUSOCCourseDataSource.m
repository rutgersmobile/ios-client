//
//  RUSOCCourseDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseDataSource.h"
#import "RUSOCSectionCell.h"
#import "ALTableViewTextCell.h"
#import "RUSOCCourseSectionsDataSource.h"
#import "RUSOCDataLoadingManager.h"

@interface RUSOCCourseDataSource ()
@property (nonatomic) NSDictionary *course;
@property (nonatomic) RUSOCCourseSectionsDataSource *sectionsDataSource;
@end

@implementation RUSOCCourseDataSource
-(id)initWithCourse:(NSDictionary *)course{
    self = [super init];
    if (self) {
        self.course = course;
        self.sectionsDataSource = [[RUSOCCourseSectionsDataSource alloc] init];
        [self addDataSource:self.sectionsDataSource];
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        NSArray *sections = self.course[@"sections"];
        if (sections) {
            [loading updateWithContent:^(typeof(self) me) {
                me.sectionsDataSource.items = sections;
            }];
        } else {
            [[RUSOCDataLoadingManager sharedInstance] getCourseForSubjectCode:self.course[@"subjectCode"] courseCode:self.course[@"courseNumber"] withSuccess:^(NSDictionary *course) {
                [loading updateWithContent:^(typeof(self) me) {
                    me.sectionsDataSource.items = course[@"sections"];
                }];
            } failure:^{
                [loading doneWithError:nil];
            }];
        }
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}


/*
 NSString *courseDescription = self.course[@"courseDescription"];
 if (courseDescription) {
 EZTableViewTextRow *row = [[EZTableViewTextRow alloc] initWithAttributedText:[[NSAttributedString alloc] initWithString:courseDescription attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}]];
 [self.dataSource addDataSource:[[EZDataSourceSection alloc] initWithItems:@[row]]];
 }
 
 EZDataSourceSection *sectionSection = [[EZDataSourceSection alloc] init];
 
  }
 [self.dataSource addDataSource:sectionSection];
 */
@end
