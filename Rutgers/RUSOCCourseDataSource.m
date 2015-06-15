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
#import "DataSource_Private.h"

@interface RUSOCCourseDataSource ()
@property (nonatomic) NSDictionary *course;
@property (nonatomic) RUSOCCourseSectionsDataSource *sectionsDataSource;
@property (nonatomic) RUSOCCourseHeaderDataSource *headerDataSource;
@end

@implementation RUSOCCourseDataSource
-(instancetype)initWithCourse:(NSDictionary *)course{
    self = [super init];
    if (self) {
        self.course = course;
        self.headerDataSource = [[RUSOCCourseHeaderDataSource alloc] init];
        self.sectionsDataSource = [[RUSOCCourseSectionsDataSource alloc] init];
    }
    return self;
}

-(void)loadContent{
    NSArray *sections = self.course[@"sections"];
    if (sections) {
        [self updateWithCourse:self.course];
    } else {
        [self loadContentWithBlock:^(AAPLLoading *loading) {
            
            [[RUSOCDataLoadingManager sharedInstance] getCourseForSubjectCode:self.course[@"subjectCode"] courseCode:self.course[@"courseNumber"] completion:^(NSDictionary *course, NSError *error) {
                if (!loading.current) {
                    [loading ignore];
                    return;
                }
                
                if (!error) {
                    [loading updateWithContent:^(typeof(self) me) {
                        [me updateWithCourse:course];
                    }];
                } else {
                    [loading doneWithError:error];
                }
            }];
            
        }];
    }
}

-(void)updateWithCourse:(NSDictionary *)course{
    self.course = course;
    [self removeAllDataSources];
    
    NSMutableDictionary *headerItems = [NSMutableDictionary dictionary];
    for (NSString *key in @[@"subjectNotes",@"preReqNotes",@"synopsisUrl"]) {
        id value = course[key];
        if (value) headerItems[key] = value;
    }
    
    if (headerItems.count) {
        self.headerDataSource.headerItems = headerItems;
        [self addDataSource:self.headerDataSource];
    }
    
    [self.sectionsDataSource loadContentWithBlock:^(AAPLLoading *loading) {
       [loading updateWithContent:^(typeof(self.sectionsDataSource) sectionsDataSource) {
           sectionsDataSource.items = course[@"sections"];
       }];
    }];
    [self addDataSource:self.sectionsDataSource];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSOCSectionCell class] forCellReuseIdentifier:NSStringFromClass([RUSOCSectionCell class])];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

@end
