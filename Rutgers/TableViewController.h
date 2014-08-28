//
//  TableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"
#import "SearchDataSource.h"

@interface TableViewController : UIViewController <UITableViewDelegate, UISearchDisplayDelegate>
-(instancetype)initWithStyle:(UITableViewStyle)style;

@property (nonatomic) UITableView *tableView;
-(UITableView *)searchTableView;

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
@end
