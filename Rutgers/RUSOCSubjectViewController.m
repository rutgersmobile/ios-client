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
    if (self) {
        self.subject = subject;
        self.title = [NSString stringWithFormat:@"%@: %@", subject[@"code"], [subject[@"description"] capitalizedString]];
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
                                                 manager.semester[@"tag"],
                                                 manager.campus[@"tag"],
                                                 manager.level[@"tag"],
                                                 self.subject[@"code"]
                                                 ]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[RUSOCSubjectDataSource alloc] initWithSubjectCode:self.subject[@"code"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCCourseRow *row = [self.dataSource itemAtIndexPath:indexPath];
    RUSOCCourseViewController *courseVC = [[RUSOCCourseViewController alloc] initWithCourse:row.course];
    courseVC.dataLoadingManager = self.dataLoadingManager;
    [self.navigationController pushViewController:courseVC animated:YES];
}
@end
