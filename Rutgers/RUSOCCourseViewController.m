//
//  RUSOCCourseViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseViewController.h"
#import "EZTableViewTextRow.h"
#import "EZTableViewSection.h"
#import "EZTableViewTextRow.h"
#import "RUSOCSectionRow.h"
#import "RUChannelManager.h"
#import "RUSOCData.h"

@interface RUSOCCourseViewController ()
@property (nonatomic) NSDictionary *course;
@end

@implementation RUSOCCourseViewController
-(id)initWithCourse:(NSDictionary *)course{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.course = course;
        self.title = [NSString stringWithFormat:@"%@: %@",self.course[@"courseNumber"],[self.course[@"title"] capitalizedString]];
        
        NSString *courseDescription = self.course[@"courseDescription"];
        if (courseDescription) {
            EZTableViewTextRow *row = [[EZTableViewTextRow alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:courseDescription attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}]];
            [self addSection:[[EZTableViewSection alloc] initWithRows:@[row]]];
        }
        
        EZTableViewSection *sectionSection = [[EZTableViewSection alloc] init];
        
        NSPredicate *printedSectionsPredicate = [NSPredicate predicateWithFormat:@"printed == %@",@"Y"];
        NSArray *sections = [self.course[@"sections"] filteredArrayUsingPredicate:printedSectionsPredicate];
        
        for (NSDictionary *section in sections) {
            RUSOCSectionRow *sectionRow = [[RUSOCSectionRow alloc] initWithSection:section];
            sectionRow.didSelectRowBlock = ^{
                NSDictionary *channel = @{@"title" : @"WebReg", @"view" : @"www", @"url" :[NSString stringWithFormat:@"https://sims.rutgers.edu/webreg/editSchedule.htm?login=cas&semesterSelection=%@&indexList=%@",[RUSOCData sharedInstance].semester[@"tag"],section[@"index"]]};
                [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:channel] animated:YES];
            };
            [sectionSection addRow:sectionRow];
        }
        [self addSection:sectionSection];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

@end
