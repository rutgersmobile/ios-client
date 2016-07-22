//
//  RUSOCSubjectViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCSubjectViewController.h"
#import "RUSOCCourseViewController.h"
#import "RUSOCCourseRow.h"
#import "RUSOCSubjectDataSource.h"
#import "NSURL+RUAdditions.h"
#import "RUSOCDataLoadingManager.h"

@interface RUSOCSubjectViewController ()
@property (nonatomic) NSDictionary *subject;
@end

@implementation RUSOCSubjectViewController
-(instancetype)initWithSubject:(NSDictionary *)subject{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.subject = subject;
        // append the subject to the title(descript) only if the subject code is not found in the
        // title
        
        if ([subject[@"description"] rangeOfString:subject[@"code"] ].location == NSNotFound) // title dont not contains code
        {
            self.title = [NSString stringWithFormat:@"%@: %@", subject[@"code"], [subject[@"description"] capitalizedString]];
        }
        else // titile contain codes
        {
            self.title = [NSString stringWithFormat:@"%@" , [subject[@"description"] capitalizedString]];
        }
    }
    return self;
}

-(RUSOCDataLoadingManager *)dataLoadingManager{
    if (!_dataLoadingManager) {
        return [RUSOCDataLoadingManager sharedInstance];
    }
    return _dataLoadingManager;
}

-(NSURL *)sharingURL{
    RUSOCDataLoadingManager *manager = self.dataLoadingManager;
    return [NSURL rutgersUrlWithPathComponents:@[
                                                 @"soc",
                                                 manager.semesterTag,
                                                 manager.campus[@"tag"],
                                                 manager.level[@"tag"],
                                                 self.subject[@"code"]
                                                 ]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[RUSOCSubjectDataSource alloc] initWithSubjectCode:self.subject[@"code"] dataLoadingManager:self.dataLoadingManager];
    // when the data has been loaded , update the title of the view controller
    [self.dataSource whenLoaded:^
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.title = ((RUSOCSubjectDataSource*)self.dataSource).subjectTitle;
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@" subject vc loaded");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCCourseRow *row = [self.dataSource itemAtIndexPath:indexPath];
    RUSOCCourseViewController *courseVC = [[RUSOCCourseViewController alloc] initWithCourse:row.course];
    courseVC.dataLoadingManager = self.dataLoadingManager;
    [self.navigationController pushViewController:courseVC animated:YES];
}
@end
