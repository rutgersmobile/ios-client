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
#import "RUSOCCourseHeaderDataSource.h"

@interface RUSOCCourseDataSource ()
@property (nonatomic) NSDictionary *course;
@property (nonatomic) RUSOCCourseSectionsDataSource *sectionsDataSource;
@property (nonatomic) RUSOCCourseHeaderDataSource *headerDataSource;
@end

@implementation RUSOCCourseDataSource
-(id)initWithCourse:(NSDictionary *)course{
    self = [super init];
    if (self) {
        self.course = course;
        self.headerDataSource = [[RUSOCCourseHeaderDataSource alloc] init];
        self.sectionsDataSource = [[RUSOCCourseSectionsDataSource alloc] init];
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        NSArray *sections = self.course[@"sections"];
        if (sections) {
            [loading updateWithContent:^(typeof(self) me) {
                [me updateWithCourse:me.course];
            }];
        } else {
            [[RUSOCDataLoadingManager sharedInstance] getCourseForSubjectCode:self.course[@"subjectCode"] courseCode:self.course[@"courseNumber"] withSuccess:^(NSDictionary *course) {
                [loading updateWithContent:^(typeof(self) me) {
                    [me updateWithCourse:course];
                }];
            } failure:^{
                [loading doneWithError:nil];
            }];
        }
    }];
}

-(void)updateWithCourse:(NSDictionary *)course{
    self.course = course;
    
    NSMutableDictionary *headerItems = [NSMutableDictionary dictionary];
    for (NSString *key in @[@"subjectNotes",@"preReqNotes",@"synopsisUrl"]) {
        id value = course[key];
        if (value) headerItems[key] = value;
    }
    
    if (headerItems.count) {
        self.headerDataSource.headerItems = headerItems;
        [self addDataSource:self.headerDataSource];
    }
    
    self.sectionsDataSource.items = course[@"sections"];
    [self addDataSource:self.sectionsDataSource];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSOCSectionCell class] forCellReuseIdentifier:NSStringFromClass([RUSOCSectionCell class])];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

@end
