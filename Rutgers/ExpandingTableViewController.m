//
//  ExpandingTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewController.h"
#import "ExpandingTableViewDataSource.h"


@interface ExpandingTableViewController ()

@end

@implementation ExpandingTableViewController 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
      [((ExpandingTableViewDataSource *)self.dataSource) toggleExpansionForSection:indexPath.section];
        

    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    }
}



-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return YES;
    
    return (indexPath.row == 0);
}

@end
