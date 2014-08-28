//
//  RUFoodViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodViewController.h"
#import "RUDiningHallViewController.h"
#import "RUFoodDataSource.h"
#import "EZTableViewRightDetailRow.h"
#import "DataTuple.h"

@implementation RUFoodViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[RUFoodViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[RUFoodDataSource alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [self.dataSource itemAtIndexPath:indexPath];
    NSDictionary *object = item.object;
    if (object[@"view"]) {
        [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:object] animated:YES];
    } else {
        if ([self isDiningHallOpen:object])
        [self.navigationController pushViewController:[[RUDiningHallViewController alloc] initWithDiningHall:object] animated:YES];
    }
}
-(BOOL)isDiningHallOpen:(NSDictionary *)diningHall{
    NSArray *meals = diningHall[@"meals"];
    for (NSDictionary *meal in meals) {
        if ([meal[@"meal_avail"] boolValue]) return YES;
    }
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [self.dataSource itemAtIndexPath:indexPath];
    NSDictionary *object = item.object;
    if (!object[@"view"]) {
        return [self isDiningHallOpen:object];
    }
    return YES;
}
@end
