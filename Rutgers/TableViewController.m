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
#import "RUAnalyticsManager.h"

#define MIN_SEARCH_DELAY 0.3
#define MAX_SEARCH_DELAY 0.8

@interface TableViewController () <UISearchResultsUpdating, UISearchDisplayDelegate, UISearchControllerDelegate>
@property (nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) TableViewController *searchResultsController;

@property (nonatomic) MSWeakTimer *minSearchTimer;
@property (nonatomic) MSWeakTimer *maxSearchTimer;
@property (nonatomic) CGFloat lastValidWidth;
@end

@implementation TableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

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
    if (self.isViewLoaded) {
        [self resetDataSource:self.dataSource];
        [self resetDataSource:self.searchDataSource];
    }
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)resetDataSource:(DataSource *)dataSource{
    dataSource.delegate = nil;
    [dataSource resetContent];
    UITableView *tableView = [self tableViewForDataSource:dataSource];
    tableView.dataSource = nil;
}

-(void)viewWillLayoutSubviews{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (width != self.lastValidWidth) [self viewDidChangeWidth];
}

-(void)viewDidChangeWidth{
    self.lastValidWidth = CGRectGetWidth(self.view.bounds);
    [self invalidateCachedHeights];
}

-(void)invalidateCachedHeightsIfNeeded{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (width != self.lastValidWidth)  {
        [self invalidateCachedHeights];
    }
}

-(void)invalidateCachedHeights{
    [self invalidateCachedHeightsForTableView:self.tableView];
    [self invalidateCachedHeightsForTableView:self.searchTableView];
}

-(void)invalidateCachedHeightsForTableView:(UITableView *)tableView{
    [[self dataSourceForTableView:tableView] invalidateCachedHeights];
    if (tableView.window) {
        [tableView beginUpdates];
        [tableView endUpdates];
    } else {
        [tableView reloadData];
    }
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
@synthesize searchDataSource = _searchDataSource;

-(void)setSearchDataSource:(DataSource<SearchDataSource> *)searchDataSource{
    if (searchDataSource && !self.searchEnabled) {
        [self enableSearch];
    }
    
    if (searchDataSource) {
        self.tableView.tableHeaderView = self.searchBar;
    }
    
    if (!searchDataSource) {
        self.tableView.tableHeaderView = nil;
    }
    
    if (self.searchController) {
        self.searchResultsController.dataSource = searchDataSource;
    } else {
        _searchDataSource.delegate = nil;
        _searchDataSource = searchDataSource;
        searchDataSource.delegate = self;
        [self setupTableView:self.searchTableView withDataSource:searchDataSource];
    }
}

-(DataSource<SearchDataSource> *)searchDataSource{
    if (self.searchController) {
        return (DataSource<SearchDataSource> *)self.searchResultsController.dataSource;
    } else {
        return _searchDataSource;
    }
}

-(void)enableSearch{
    if ([UISearchController class]) {
        self.definesPresentationContext = YES;
        TableViewController *searchResultsController = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
        self.searchResultsController = searchResultsController;
        searchResultsController.tableView.delegate = self;
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:[[UINavigationController alloc] initWithRootViewController:searchResultsController]];
        self.searchBar = self.searchController.searchBar;
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        [RUAppearance applyAppearanceToSearchBar:self.searchBar];
        
        self.searchController.delegate = self;
        self.searchController.searchResultsUpdater = self;
        
    } else {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        [RUAppearance applyAppearanceToSearchBar:self.searchBar];
        
        self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        self.mySearchDisplayController.searchResultsDelegate = self;
        self.mySearchDisplayController.delegate = self;
        self.mySearchDisplayController.searchResultsTableView.estimatedRowHeight = 44.0;
    }
    self.searchEnabled = YES;
}

-(void)setupTableView:(UITableView *)tableView withDataSource:(DataSource *)dataSource{
    tableView.dataSource = dataSource;
    [dataSource registerReusableViewsWithTableView:tableView];
    [tableView reloadData];
}

-(UITableView *)searchTableView{
    if (self.searchController) return self.searchResultsController.tableView;
    else return self.mySearchDisplayController.searchResultsTableView;
}
 
 #pragma mark - SearchDisplayController Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self updateTimersForKeyPress];
    return NO;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    [self updateTimersForKeyPress];
}

-(void)updateTimersForKeyPress{
    [self.minSearchTimer invalidate];
    self.minSearchTimer = nil;
    self.minSearchTimer = [MSWeakTimer scheduledTimerWithTimeInterval:MIN_SEARCH_DELAY target:self selector:@selector(searchTimerFired) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    if (!self.maxSearchTimer) {
        self.maxSearchTimer = [MSWeakTimer scheduledTimerWithTimeInterval:MAX_SEARCH_DELAY target:self selector:@selector(searchTimerFired) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    }
}

-(void)searchTimerFired{
    if (self.searchController) {
        DataSource *dataSource = self.searchResultsController.dataSource;
        if ([dataSource conformsToProtocol:@protocol(SearchDataSource)]) {
            DataSource<SearchDataSource> *searchDataSource = (DataSource<SearchDataSource>*)dataSource;
            [searchDataSource updateForQuery:self.searchBar.text];
        }
    } else {
        [self.searchDataSource updateForQuery:self.searchBar.text];
    }
    [self invalidateSearchTimers];
}

-(void)invalidateSearchTimers{
    [self.minSearchTimer invalidate];
    self.minSearchTimer = nil;
    [self.maxSearchTimer invalidate];
    self.maxSearchTimer = nil;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [self presentSearch];
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [self dismissSearch];
}

- (void)willPresentSearchController:(UISearchController *)searchController{
    [self presentSearch];
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    [self dismissSearch];
}

-(void)presentSearch{
    [self setStatusAppearanceForSearchingState:YES];
    self.searching = YES;
}

-(void)dismissSearch{
    [self setStatusAppearanceForSearchingState:NO];
    self.searching = NO;
    [self invalidateSearchTimers];
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
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[RUAnalyticsManager sharedManager] queueEventForUserInteraction:[self userInteractionForTableView:tableView rowAtIndexPath:indexPath]];
    return indexPath;
}

-(NSDictionary *)userInteractionForTableView:(UITableView *)tableView rowAtIndexPath:(NSIndexPath *)indexPath{
    return @{@"indexPath" : indexPath.description,
             @"description" : [[[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath] description]? : @"null"};
}

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
-(UITableViewRowAnimation)rowAnimationForOperationDirection:(DataSourceAnimationDirection)direction{
    switch (direction) {
        case DataSourceAnimationDirectionNone:
            return UITableViewRowAnimationFade;
            break;
        case DataSourceAnimationDirectionLeft:
            return UITableViewRowAnimationLeft;
            break;
        case DataSourceAnimationDirectionRight:
            return UITableViewRowAnimationRight;
            break;
    }
}

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimationDirection)direction{
    [[self tableViewForDataSource:dataSource] insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimationDirection)direction{
    [[self tableViewForDataSource:dataSource] deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimationDirection)direction{
    [[self tableViewForDataSource:dataSource] reloadRowsAtIndexPaths:refreshedIndexPaths withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    [[self tableViewForDataSource:dataSource] moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    [[self tableViewForDataSource:dataSource] reloadSections:sections withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    [[self tableViewForDataSource:dataSource] insertSections:sections withRowAnimation:[self rowAnimationForOperationDirection:direction]];
}

-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
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
