//
//  recreation.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecreationViewController.h"
#import "RURecCenterViewController.h"
#import "RURecCenterDataSource.h"
#import "DataTuple.h"

@interface RURecreationViewController ()
@property (nonatomic) NSDictionary *recData;
@end

@implementation RURecreationViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[RURecreationViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[RURecCenterDataSource alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *recCenter = [self.dataSource itemAtIndexPath:indexPath];
   
    RURecCenterViewController *recVC = [[RURecCenterViewController alloc] initWithTitle:recCenter.title recCenter:recCenter.object];
    [self.navigationController pushViewController:recVC animated:YES];
}
@end
