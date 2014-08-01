//
//  RUFoodViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodViewController.h"
#import "RUDiningHallViewController.h"
#import "RUChannelManager.h"
#import "RUFoodDataSource.h"
#import "EZTableViewRightDetailRow.h"
#import "DataTuple.h"

@implementation RUFoodViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUFoodViewController alloc] init];
}
- (instancetype)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   //[self setupContentLoadingStateMachine];
    self.dataSource = [[RUFoodDataSource alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [self.dataSource itemAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        [self.navigationController pushViewController:[[RUDiningHallViewController alloc] initWithDiningHall:item.object] animated:YES];
    } else {
        [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:item.object] animated:YES];
    }
}
@end
