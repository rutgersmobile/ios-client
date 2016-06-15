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

@interface RUSOCSubjectDataSource ()
@property (nonatomic) RUSOCDataLoadingManager *dataLoadingManager;
@property (nonatomic) NSString *subjectCode;
@end

@implementation RUSOCSubjectDataSource
-(instancetype)initWithSubjectCode:(NSString *)subjectCode dataLoadingManager:(RUSOCDataLoadingManager *)dataLoadingManager{
    self = [super init];
    if (self) {
        self.subjectCode = subjectCode;
        self.title = @"Courses";
        self.dataLoadingManager = dataLoadingManager;
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [self.dataLoadingManager getCoursesForSubjectCode:self.subjectCode completion:^(NSArray *courses, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if (!error) {
                [loading updateWithContent:^(typeof(self) me) {
                    [self updateWithCourses:courses];
                }];
            } else {
                [loading doneWithError:error];
            }
        }];
    }];
}

-(void)updateWithCourses:(NSArray *)courses{
    NSMutableArray *parsedItems = [NSMutableArray array];
    for (NSDictionary *course in courses) {
        RUSOCCourseRow *row = [[RUSOCCourseRow alloc] initWithCourse:course];
        [parsedItems addObject:row];
    }
    self.items = parsedItems;
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
