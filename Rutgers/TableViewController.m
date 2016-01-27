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
#import "RUAppearance.h"
#import "RUFavoriteActivity.h"

#define MIN_SEARCH_DELAY 0.3
#define MAX_SEARCH_DELAY 0.8

@interface TableViewController () <UISearchResultsUpdating, UISearchDisplayDelegate, UISearchControllerDelegate, UIPopoverControllerDelegate>
@property (nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) TableViewController *searchResultsController;

@property (nonatomic) NSTimer *minSearchTimer;
@property (nonatomic) NSTimer *maxSearchTimer;
@property (nonatomic) BOOL wasSearching;
@property (nonatomic) NSString *lastSearchQuery;

@property (nonatomic) CGFloat lastValidWidth;

@property (nonatomic) UIBarButtonItem *shareButton;
@property (nonatomic) UIPopoverController *sharingPopoverController;
@end

@implementation TableViewController
#pragma mark - Lifecycle
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
  
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    #endif
    
    if (self.sharingURL) {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
        self.shareButton = shareButton;
        self.navigationItem.rightBarButtonItem = shareButton;
    }

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
    
    if (self.wasSearching) {
        [self popSearching];
        if (self.searching) {
            [self setStatusAppearanceForSearchingState:YES];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.searching) {
        [self setStatusAppearanceForSearchingState:NO];
        [self pushSearching];
    }
}

-(void)viewWillLayoutSubviews{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (width != self.lastValidWidth) [self viewDidChangeWidth];
}

-(void)dealloc{
    if (self.isViewLoaded) {
        [self resetDataSource:self.dataSource];
        [self resetDataSource:self.searchDataSource];
    }
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reloadTablePreservingSelectionState:(UITableView *)tableView{
    NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
    [tableView reloadData];
    [tableView selectRowsAtIndexPaths:selectedIndexPaths animated:NO];
}

#pragma mark - Row Height Cache
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

#pragma mark - Deep Linking
-(NSURL *)sharingURL{
    return nil;
}

-(NSString *)handle{
    [NSException raise:@"Sharing url but no handle" format:@"Class %@",NSStringFromClass([self class])];
    return nil;
}

- (void)actionButtonTapped:(id)sender {
    NSURL *url = self.sharingURL;
    if (!url) return;
    
    UIActivity *favoriteActivity = [[RUFavoriteActivity alloc] initWithTitle:self.title handle:self.handle];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[favoriteActivity]];
    activityViewController.excludedActivityTypes = @[
                                                     UIActivityTypePrint
                                                     ];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        //If we're on an iPhone, we can just present it modally
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        //UIPopoverController requires we retain our own instance of it.
        //So if we somehow have a prior instance, clean it out
        if (self.sharingPopoverController)
        {
            [self.sharingPopoverController dismissPopoverAnimated:NO];
            self.sharingPopoverController = nil;
        }
        
        //Create the sharing popover controller
        self.sharingPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        self.sharingPopoverController.delegate = self;
        [self.sharingPopoverController presentPopoverFromBarButtonItem:self.shareButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


#pragma mark - Data Source
-(void)setDataSource:(DataSource *)dataSource{
    _dataSource.delegate = nil;
    _dataSource = dataSource;
    dataSource.delegate = self;
    [self setupTableView:self.tableView withDataSource:dataSource];
}

-(void)resetDataSource:(DataSource *)dataSource{
    dataSource.delegate = nil;
    UITableView *tableView = [self tableViewForDataSource:dataSource];
    tableView.dataSource = nil;
    [dataSource resetContent];
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
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
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
    if (!self.isViewLoaded) return nil;
    if (self.searchController) return self.searchResultsController.tableView;
    else return self.mySearchDisplayController.searchResultsTableView;
}

#pragma Mark - Searching
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
    self.minSearchTimer = [NSTimer scheduledTimerWithTimeInterval:MIN_SEARCH_DELAY target:self selector:@selector(searchTimerFired) userInfo:nil repeats:NO];
    if (!self.maxSearchTimer) {
        self.maxSearchTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_SEARCH_DELAY target:self selector:@selector(searchTimerFired) userInfo:nil repeats:NO];
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

-(void)pushSearching{
    self.wasSearching = YES;
    self.lastSearchQuery = self.searchController.searchBar.text;
    self.searchController.active = NO;
}

-(void)popSearching{
    self.wasSearching = NO;
    self.searchController.active = YES;
    self.searchController.searchBar.text = self.lastSearchQuery;
    self.lastSearchQuery = nil;
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

#pragma mark - Data Source Delegate
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

-(void)dataSourceDidReloadData:(DataSource *)dataSource direction:(DataSourceAnimationDirection)direction{
    UITableView *tableView = [self tableViewForDataSource:dataSource];
    [tableView reloadData];
    if (direction != DataSourceAnimationDirectionNone) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:(direction == DataSourceAnimationDirectionLeft) ? kCATransitionFromRight : kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.1 :0 :0.2 :1]];
        [animation setDuration:0.55];
        [[tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    }
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
    if (!self.pullsToRefresh) return;
        
    if (!self.refreshControl && !error) {
        //After first load, add the refresh control to let the user pull to refresh
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self.dataSource action:@selector(setNeedsLoadContent) forControlEvents:UIControlEventValueChanged];
    }
    //If the refresh control was refreshing, stop it
    [self.refreshControl endRefreshing];
}

@end
