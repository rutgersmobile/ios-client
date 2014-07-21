//
//  ExpandingTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewController.h"
#import "ExpandingTableViewSection.h"
#import "NSIndexPath+RowExtensions.h"

@interface ExpandingTableViewController ()
@end

@implementation ExpandingTableViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.estimatedRowHeight = 0;
}

@end
