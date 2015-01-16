//
//  TableViewController_Private.h
//  Rutgers
//
//  Created by Kyle Bailey on 9/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TableViewController.h"
@interface TableViewController ()

@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

-(DataSource *)dataSource;
-(void)setDataSource:(DataSource *)dataSource;

-(DataSource<SearchDataSource> *)searchDataSource;
-(void)setSearchDataSource:(DataSource<SearchDataSource> *)searchDataSource;

-(DataSource *)dataSourceForTableView:(UITableView *)tableView;
-(UITableView *)tableViewForDataSource:(DataSource *)dataSource;

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller NS_REQUIRES_SUPER;
-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller NS_REQUIRES_SUPER;

@property (nonatomic, getter = isSearching) BOOL searching;
@property (nonatomic) UISearchBar *searchBar;

-(void)preferredContentSizeChanged NS_REQUIRES_SUPER;
-(void)reloadTablePreservingSelectionState:(UITableView *)tableView;

-(UITableViewRowAnimation)rowAnimationForOperationDirection:(DataSourceAnimation)direction;
@end
