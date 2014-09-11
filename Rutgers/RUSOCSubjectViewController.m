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
#import "TableViewController_Private.h"

@interface RUSOCSubjectViewController ()
@property (nonatomic) NSString *subjectCode;
@end

@implementation RUSOCSubjectViewController
-(id)initWithSubject:(NSDictionary *)subject{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.subjectCode = subject[@"code"];
        self.title = [NSString stringWithFormat:@"%@: %@", subject[@"code"], [subject[@"description"] capitalizedString]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[RUSOCSubjectDataSource alloc] initWithSubjectCode:self.subjectCode];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSOCCourseRow *row = [self.dataSource itemAtIndexPath:indexPath];
    [self.navigationController pushViewController:[[RUSOCCourseViewController alloc] initWithCourse:row.course] animated:YES];
}
@end
