//
//  TableViewController_Private.h
//  Rutgers
//
//  Created by Kyle Bailey on 9/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TableViewController.h"
@interface TableViewController ()

@property (nonatomic) BOOL searchEnabled;
-(void)enableSearch;

-(void)presentSearch NS_REQUIRES_SUPER;
-(void)dismissSearch NS_REQUIRES_SUPER;

-(void)viewDidChangeWidth;

@property (nonatomic) BOOL loadsContentOnViewWillAppear;

@property (nonatomic) DataSource *dataSource;
@property (nonatomic) DataSource<SearchDataSource> *searchDataSource;

-(DataSource *)dataSourceForTableView:(UITableView *)tableView;
-(UITableView *)tableViewForDataSource:(DataSource *)dataSource;

@property (nonatomic, getter = isSearching) BOOL searching;
@property (nonatomic) UISearchBar *searchBar;

-(void)preferredContentSizeChanged NS_REQUIRES_SUPER;
-(void)reloadTablePreservingSelectionState:(UITableView *)tableView;

-(UITableViewRowAnimation)rowAnimationForOperationDirection:(DataSourceAnimationDirection)direction;
@end
