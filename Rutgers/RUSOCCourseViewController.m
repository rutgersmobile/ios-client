//
//  RUSOCCourseViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseViewController.h"
#import "RUSOCSectionRow.h"
#import "RUSOCCourseDataSource.h"
#import "RUSOCDataLoadingManager.h"
#import "DataTuple.h"

@interface RUSOCCourseViewController ()
@property (nonatomic) NSDictionary *course;
@end

@implementation RUSOCCourseViewController
-(id)initWithCourse:(NSDictionary *)course{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.course = course;
        self.title = [self.course[@"title"] capitalizedString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorColor = [[UIColor blackColor] colorWithAlphaComponent:0.17];
    self.dataSource = [[RUSOCCourseDataSource alloc] initWithCourse:self.course];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[RUSOCSectionRow class]]) {
        RUSOCSectionRow *sectionRow = [self.dataSource itemAtIndexPath:indexPath];
        
        NSDictionary *channel = @{@"title" : @"WebReg", @"view" : @"www", @"url" :[NSString stringWithFormat:@"https://sims.rutgers.edu/webreg/editSchedule.htm?login=cas&semesterSelection=%@&indexList=%@",[RUSOCDataLoadingManager sharedInstance].semester[@"tag"],sectionRow.section[@"index"]]};
        [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:channel] animated:YES];
    } else if ([item isKindOfClass:[DataTuple class]]) {
        DataTuple *tuple = item;
        if ([tuple.title isEqualToString:@"Prerequisites"]) {
            [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : tuple.title, @"view" : @"text", @"data" : tuple.object, @"centersText" : @YES}] animated:YES];
        } else if ([tuple.title isEqualToString:@"Synopsis"]) {
            [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : tuple.title, @"view" : @"www", @"url" : tuple.object}] animated:YES];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[DataTuple class]]) {
        DataTuple *tuple = item;
        if (!tuple.object) return NO;
    }
    return YES;
}

@end
