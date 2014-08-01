//
//  ExpandingTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewController.h"
#import "ExpandingTableViewDataSource.h"
#import "DataSource_Private.h"

@interface ExpandingTableViewController () <DataSourceDelegate>
@end

@implementation ExpandingTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.estimatedRowHeight = 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [((ExpandingTableViewDataSource *)self.dataSource) tableView:tableView didSelectRowAtIndexPath:indexPath];
}
@end
