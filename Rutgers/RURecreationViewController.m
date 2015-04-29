//
//  recreation.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecreationViewController.h"
#import "RURecCenterViewController.h"
#import "RURecreationDataSource.h"
#import "DataTuple.h"
#import "TableViewController_Private.h"

@interface RURecreationViewController ()
@property (nonatomic) NSDictionary *recData;
@end

@implementation RURecreationViewController
+(instancetype)newWithOptions:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[RURecreationDataSource alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *recCenter = [self.dataSource itemAtIndexPath:indexPath];
   
    RURecCenterViewController *recVC = [[RURecCenterViewController alloc] initWithTitle:recCenter.title recCenter:recCenter.object];
    [self.navigationController pushViewController:recVC animated:YES];
}
@end
