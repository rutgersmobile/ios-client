//
//  TableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "TableViewController.h"
#import "RUNavigationController.h"
#import "UITableView+Selection.h"
#import "TableViewController_Private.h"
#import "AAPLPlaceholderView.h"

@interface TableViewController () 
@property (nonatomic) DataSource *dataSource;
@property (nonatomic) DataSource<SearchDataSource> *searchDataSource;
@property (nonatomic) BOOL searchEnabled;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) BOOL loadsContentOnViewWillAppear;
//@property (nonatomic, readonly) UITableViewStyle style;
@property (nonatomic) CGFloat lastValidWidth;
@end

@implementation TableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, kLabelHorizontalInsets, 0, 0);
    self.tableView.estimatedRowHeight = 44.0;
    self.lastValidWidth = CGRectGetWidth(self.tableView.bounds);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self invalidateCachedHeightsIfNeeded];
    
    if (self.clearsSelectionOnViewWillAppear) {
        [self.tableView clearSelectionAnimated:YES];
    }

    if (self.loadsContentOnViewWillAppear || [self.dataSource.loadingState isEqualToString:AAPLLoadStateInitial]) {
        [self.dataSource setNeedsLoadContent];
    }
    
    if (self.loadsContentOnViewWillAppear || [self.searchDataSource.loadingState isEqualToString:AAPLLoadStateInitial]) {
        [self.searchDataSource setNeedsLoadContent];
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

-(void)dealloc{
    self.dataSource.delegate = nil;
    self.searchDataSource.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillLayoutSubviews{
    [self invalidateCachedHeightsIfNeeded];
}

-(void)invalidateCachedHeightsIfNeeded{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (width != self.lastValidWidth) [self invalidateCachedHeights];
}

-(void)invalidateCachedHeights{
    self.lastValidWidth = CGRectGetWidth(self.view.bounds);
    [self invalidateCachedHeightsForTableView:self.tableView];
    [self invalidateCachedHeightsForTableView:self.searchTableView];
}

-(void)invalidateCachedHeightsForTableView:(UITableView *)tableView{
    [[self dataSourceForTableView:tableView] invalidateCachedHeights];
    [tableView beginUpdates];
    [tableView endUpdates];
}

-(void)preferredContentSizeChanged{
    [self invalidateCachedHeights];
    
    [self reloadTablePreservingSelectionState:self.tableView];
    [self reloadTablePreservingSelectionState:self.searchTableView];
}

-(void)reloadTablePreservingSelectionState:(UITableView *)tableView{
    NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
    [tableView reloadData];
    [tableView selectRowsAtIndexPaths:selectedIndexPaths animated:NO];
}

#pragma mark - Data Source
-(void)setDataSource:(DataSource *)dataSource{
    _dataSource.delegate = nil;
    _dataSource = dataSource;
    dataSource.delegate = self;
    [self setupTableView:self.tableView withDataSource:dataSource];
}

#pragma mark - Search Data Source
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
    return [[self dataSourceForTableView:tableView] tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self dataSourceForTableView:tableView] tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ALPlaceholderCell class]] || [cell isKindOfClass:[ALActivityIndicatorCell class]]) return NO;
    return YES;
}

#pragma mark - Data Source notifications
-(UITableViewRowAnimation)rowAnimationForOperationDirection:(DataSourceAnimation)direction{
    switch (direction) {
        case DataSourceAnimationFade:
            return UITableViewRowAnimationFade;
            break;
        case DataSourceAnimationLeft:
            return UITableViewRowAnimationLeft;
            break;
        case DataSourceAnimationRight:
            return UITableViewRowAnimationRight;
            break;
    }
}

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimation)direction{
    [[self tableViewForDataSource:dataSource] insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimation)direction{
    [[self tableViewForDataSource:dataSource] deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimation)direction{
    [[self tableViewForDataSource:dataSource] reloadRowsAtIndexPaths:refreshedIndexPaths withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    [[self tableViewForDataSource:dataSource] moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceAnimation)direction{
    [[self tableViewForDataSource:dataSource] reloadSections:sections withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceAnimation)direction{
    [[self tableViewForDataSource:dataSource] insertSections:sections withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceAnimation)direction{
    [[self tableViewForDataSource:dataSource] deleteSections:sections withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection{
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
