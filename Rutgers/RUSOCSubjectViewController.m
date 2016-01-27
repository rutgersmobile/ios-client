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

-(NSURL *)sharingURL{
    RUSOCDataLoadingManager *manager = [RUSOCDataLoadingManager sharedInstance];
    return [NSURL rutgersUrlWithPathComponents:@[
                                                 @"soc",
                                                 manager.semester[@"tag"],
                                                 manager.campus[@"tag"],
                                                 manager.level[@"tag"],
                                                 self.subject[@"code"]
                                                 ]];
}

-(NSString *)handle{
    return @"soc";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[RUSOCSubjectDataSource alloc] initWithSubjectCode:self.subject[@"code"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCCourseRow *row = [self.dataSource itemAtIndexPath:indexPath];
    [self.navigationController pushViewController:[[RUSOCCourseViewController alloc] initWithCourse:row.course] animated:YES];
}
@end
