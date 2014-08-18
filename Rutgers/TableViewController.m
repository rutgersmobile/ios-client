//
//  TableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "TableViewController.h"
#import "DataSource_Private.h"
#import "RUNavigationController.h"

@interface TableViewController () <DataSourceDelegate>
@property (nonatomic) DataSource *dataSource;
@property (nonatomic) DataSource<SearchDataSource> *searchDataSource;
@property (nonatomic) BOOL searchEnabled;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) BOOL loadsContentOnViewWillAppear;
@property (nonatomic, readonly) UITableViewStyle style;

@end

@implementation TableViewController
-(id)init{
    self = [super init];
    if (self) {
        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

-(instancetype)initWithStyle:(UITableViewStyle)style{
    self = [self init];
    if (self) {
        _style = style;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.style];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44.0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.clearsSelectionOnViewWillAppear) {
        [self clearSelection];
    }

    if (self.loadsContentOnViewWillAppear || [self.dataSource.loadingState isEqualToString:AAPLLoadStateInitial]) {
        [self.dataSource setNeedsLoadContent];
    }
    
    if (self.loadsContentOnViewWillAppear || [self.searchDataSource.loadingState isEqualToString:AAPLLoadStateInitial]) {
        [self.searchDataSource setNeedsLoadContent];
    }

}

-(void)clearSelection{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in indexPaths) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.searching) {
        [self setStatusAppearanceForSearchingState:YES];
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.searching) {
        [self setStatusAppearanceForSearchingState:NO];
    }
}

#pragma mark - Data Source
@synthesize dataSource = _dataSource;
-(DataSource *)dataSource{
    return _dataSource;
}

-(void)setDataSource:(DataSource *)dataSource{
    _dataSource.delegate = nil;
    _dataSource = dataSource;
    dataSource.delegate = self;
    [self setupTableView:self.tableView withDataSource:dataSource];
}

#pragma mark - Search Data Source
@synthesize searchDataSource = _searchDataSource;
-(DataSource<SearchDataSource> *)searchDataSource{
    return _searchDataSource;
}

-(void)setSearchDataSource:(DataSource<SearchDataSource> *)searchDataSource{
    if (searchDataSource && !self.searchEnabled) {
        [self enableSearch];
    }
    
    if (!_searchDataSource && searchDataSource) {
        self.tableView.tableHeaderView = self.searchBar;
    }
    
    if (_searchDataSource && !searchDataSource) {
        [self.searchBar removeFromSuperview];
    }
    
    _searchDataSource.delegate = nil;
    _searchDataSource = searchDataSource;
    searchDataSource.delegate = self;
    [self setupTableView:self.searchTableView withDataSource:searchDataSource];
}

-(void)enableSearch{
     self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
     [RUAppearance applyAppearanceToSearchBar:self.searchBar];
     
     self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
     self.searchController.searchResultsDelegate = self;
     self.searchController.delegate = self;
     self.searchController.searchResultsTableView.estimatedRowHeight = 44.0;
    
     self.searchEnabled = YES;
}

-(void)setupTableView:(UITableView *)tableView withDataSource:(DataSource *)dataSource{
    tableView.dataSource = dataSource;
    [dataSource registerReusableViewsWithTableView:tableView];
    [tableView reloadData];
}

-(UITableView *)searchTableView{
    return self.searchController.searchResultsTableView;
}
 
 #pragma mark - SearchDisplayController Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.searchDataSource updateForQuery:searchString];
    return NO;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [self setStatusAppearanceForSearchingState:YES];
    self.searching = YES;
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [self setStatusAppearanceForSearchingState:NO];
    self.searching = NO;
    [UIView performWithoutAnimation:^{
        [self.searchDataSource resetContent];
    }];
}

-(void)setStatusAppearanceForSearchingState:(BOOL)searching{
    id navigationController = self.navigationController;
    if ([navigationController isKindOfClass:[RUNavigationController class]]) {
        RUNavigationController *navController = navigationController;
        navController.preferredStatusBarStyle = (searching ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
    }
}

#pragma mark - TableView Delegate
-(DataSource *)dataSourceForTableView:(UITableView *)tableView{
    if ([tableView.dataSource isKindOfClass:[DataSource class]]) return (DataSource *)tableView.dataSource;
    return nil;
}

-(UITableView *)tableViewForDataSource:(DataSource *)dataSource{
    if (dataSource == self.dataSource) return self.tableView;
    else if (dataSource == self.searchDataSource) return self.searchTableView;
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self dataSourceForTableView:tableView] tableView:tableView heightForRowAtIndexPath:indexPath] + 1;
}

#pragma mark - Data Source notifications
-(UITableViewRowAnimation)rowAnimationForSectionOperationDirection:(DataSourceOperationDirection)direction{
    switch (direction) {
        case DataSourceOperationDirectionNone:
            return UITableViewRowAnimationAutomatic;
            break;
        case DataSourceOperationDirectionLeft:
            return UITableViewRowAnimationLeft;
            break;
        case DataSourceOperationDirectionRight:
            return UITableViewRowAnimationRight;
            break;
    }
}

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths{
    [[self tableViewForDataSource:dataSource] insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths{
    [[self tableViewForDataSource:dataSource] deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths{
    [[self tableViewForDataSource:dataSource] reloadRowsAtIndexPaths:refreshedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    [[self tableViewForDataSource:dataSource] moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [[self tableViewForDataSource:dataSource] reloadSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [[self tableViewForDataSource:dataSource] insertSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [[self tableViewForDataSource:dataSource] deleteSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection direction:(DataSourceOperationDirection)direction{
    [[self tableViewForDataSource:dataSource] moveSection:section toSection:newSection];
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource{
    [[self tableViewForDataSource:dataSource] reloadData];
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    UITableView *tableView = [self tableViewForDataSource:dataSource];
    
    [tableView beginUpdates];
    if (update) {
        update();
    }
    [tableView endUpdates];
    
    if (complete) {
        complete();
    }
}

-(void)dataSourceWillLoadContent:(DataSource *)dataSource{
    
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    
}

@end
