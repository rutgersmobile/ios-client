//
//  TableViewController.h
//  RUThereYet?
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"
#import "SearchDataSource.h"

@interface TableViewController : UITableViewController
-(UITableView *)searchTableView;
-(DataSource *)dataSource;
-(void)setDataSource:(DataSource *)dataSource;

-(DataSource<SearchDataSource> *)searchDataSource;
-(void)setSearchDataSource:(DataSource<SearchDataSource> *)searchDataSource;
@end
