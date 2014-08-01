//
//  RUSOCCourseViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseViewController.h"
#import "EZTableViewTextRow.h"
#import "EZDataSource.h"
#import "EZTableViewTextRow.h"
#import "RUSOCSectionRow.h"
#import "RUChannelManager.h"
#import "RUSOCDataLoadingManager.h"

@interface RUSOCCourseViewController ()
@property (nonatomic) NSDictionary *course;
@end

@implementation RUSOCCourseViewController
-(id)initWithCourse:(NSDictionary *)course{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.course = course;
        self.title = [NSString stringWithFormat:@"%@: %@",self.course[@"courseNumber"],[self.course[@"title"] capitalizedString]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [[UIColor blackColor] colorWithAlphaComponent:0.17];
    [self makeSections];
}

-(void)makeSections{
    
    NSString *courseDescription = self.course[@"courseDescription"];
    if (courseDescription) {
        EZTableViewTextRow *row = [[EZTableViewTextRow alloc] initWithAttributedText:[[NSAttributedString alloc] initWithString:courseDescription attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}]];
        [self.dataSource addSection:[[EZDataSourceSection alloc] initWithItems:@[row]]];
    }
    
    EZDataSourceSection *sectionSection = [[EZDataSourceSection alloc] init];
    
    NSPredicate *printedSectionsPredicate = [NSPredicate predicateWithFormat:@"printed == %@",@"Y"];
    NSArray *sections = [self.course[@"sections"] filteredArrayUsingPredicate:printedSectionsPredicate];
    
    for (NSDictionary *section in sections) {
        RUSOCSectionRow *sectionRow = [[RUSOCSectionRow alloc] initWithSection:section];
        UINavigationController *navController = self.navigationController;
        sectionRow.didSelectRowBlock = ^{
            NSDictionary *channel = @{@"title" : @"WebReg", @"view" : @"www", @"url" :[NSString stringWithFormat:@"https://sims.rutgers.edu/webreg/editSchedule.htm?login=cas&semesterSelection=%@&indexList=%@",[RUSOCDataLoadingManager sharedInstance].semester[@"tag"],section[@"index"]]};
            [navController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:channel] animated:YES];
        };
        [sectionSection addItem:sectionRow];
    }
    [self.dataSource addSection:sectionSection];
}

@end
