//
//  ExpandingTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewController.h"
#import "ExpandingTableViewDataSource.h"
#import "TableViewController_Private.h"

@interface ExpandingTableViewController () <DataSourceDelegate>
@end

@implementation ExpandingTableViewController
/*
-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 0;
}

-(BOOL)respondsToSelector:(SEL)aSelector{
    if (@selector(tableView:estimatedHeightForRowAtIndexPath:) == aSelector) return NO;
    return [super respondsToSelector:aSelector];
}*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
      [((ExpandingTableViewDataSource *)self.dataSource) toggleExpansionForSection:indexPath.section];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
