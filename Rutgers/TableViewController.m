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

/*
    Generic table view controller that displays the data for all the different source ?
 */
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

    
    // chanage the format if the user font preference has changed
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
    
    if (self.sharingURL) { // sharingURL is implemented in the respective source sub class .. This TableView is an abstract class
        // What does the shareButton do ????? <q>
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
        self.shareButton = shareButton;
        self.navigationItem.rightBarButtonItem = shareButton;
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self invalidateCachedHeightsIfNeeded];

        // Based on the state the data source is made to load content
    // Set up both the data source and the search data source
    if (self.loadsContentOnViewWillAppear || [self.dataSource.loadingState isEqualToString:AAPLLoadStateInitial]) {
        [self.dataSource setNeedsLoadContent];
    }
    
    if (self.loadsContentOnViewWillAppear || [self.searchDataSource.loadingState isEqualToString:AAPLLoadStateInitial]) {
        [self.searchDataSource setNeedsLoadContent];
    }
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.wasSearching) { // if a search was being conducted then show it again
        [self popSearching];
        if (self.searching) {
            [self setStatusAppearanceForSearchingState:YES];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // if we where conduction a search store the search instance with the string being used to serach for use
    // when the view appreace again
    if (self.searching) {
        [self setStatusAppearanceForSearchingState:NO];
        [self pushSearching];
    }
}

/*
    called before the subviews are added , if the width has chaned call viewDidCha...Heig..
 */
-(void)viewWillLayoutSubviews{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (width != self.lastValidWidth) [self viewDidChangeWidth];
}

/*
    deallocates the data soruce and search data source
 */

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

/*
    Manages the display of objects
 */
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

-(NSString *)sharingTitle{
    return self.title;
}


/*
    <q> ?????
    This button seems to be used for adding the favoutes button to the slide view controller
 
 */
- (void)actionButtonTapped:(id)sender {
    NSURL *url = self.sharingURL;
    if (!url) return;
   
    /*
        An abstract class used to provide the service of adding favourtes to the app
     */
    UIActivity *favoriteActivity = [[RUFavoriteActivity alloc] initWithTitle:self.sharingTitle];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[favoriteActivity]];
    activityViewController.excludedActivityTypes = @[
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAddToReadingList,
                                                     
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

/*
    Data source is set by : <q>
 
 */
#pragma mark - Data Source
-(void)setDataSource:(DataSource *)dataSource{
    _dataSource.delegate = nil;
    _dataSource = dataSource;
    dataSource.delegate = self;
    [self setupTableView:self.tableView withDataSource:dataSource];
}

/*
    Reset Data source and add it to the tableViewCon
 */
-(void)resetDataSource:(DataSource *)dataSource{
    dataSource.delegate = nil;
    UITableView *tableView = [self tableViewForDataSource:dataSource];
    tableView.dataSource = nil;
    [dataSource resetContent];
}

/*
 obtain the data source for the table view controller 
 */
-(DataSource *)dataSourceForTableView:(UITableView *)tableView{
    if ([tableView.dataSource isKindOfClass:[DataSource class]]) return (DataSource *)tableView.dataSource;
    return nil;
}

/*
    obtain the table vc for a given data source
        if the data source belongs to the current class , then simply return the table view for it 
    else 
        search ???? <q>
 */

-(UITableView *)tableViewForDataSource:(DataSource *)dataSource{
    if (dataSource == self.dataSource) return self.tableView;
    else if (dataSource == self.searchDataSource) return self.searchTableView;
    return nil;
}

#pragma mark - Search Data Source
@synthesize searchDataSource = _searchDataSource;

/*
    Set the searchData source for the current table vc .
 
 */
-(void)setSearchDataSource:(DataSource<SearchDataSource> *)searchDataSource{
    if (searchDataSource && !self.searchEnabled) {
        [self enableSearch]; // allow searc
    }
    
    if (searchDataSource) {
        self.tableView.tableHeaderView = self.searchBar;
    }
    
    if (!searchDataSource) {
        self.tableView.tableHeaderView = nil;
    }
   
        /*
            After obtaining the controller for a particule search , attach the search data source to it .
         */
    if (self.searchController) {
        self.searchResultsController.dataSource = searchDataSource;
    } else {
        /*
            if not , sets up the search data source to be used with the search table view
         */
        _searchDataSource.delegate = nil;
        _searchDataSource = searchDataSource;
        searchDataSource.delegate = self;
        [self setupTableView:self.searchTableView withDataSource:searchDataSource]; // set up the table view to be search table view with the search data source
    }
}

/*
    if the controller is a search controller , then return the result data source , other wise , return the 
    data source set up by some other class
 */
-(DataSource<SearchDataSource> *)searchDataSource{
    
    if (self.searchController) {
        return (DataSource<SearchDataSource> *)self.searchResultsController.dataSource;
    } else {
        return _searchDataSource;
    }
}

/*
    Allow to search the current view for the particular item 
 
 */
-(void)enableSearch{
    /*
        UISearchController manages two classes , one the current class with the data that is being displayed and the other class the view that you want to display the search results in .
     
     */
    if ([UISearchController class]) { // may be for higher ios version ?
        self.definesPresentationContext = YES;
        TableViewController *searchResultsController = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
        // serachRes...Con is displayed when the user seraches in the UISea...Contr..
        self.searchResultsController = searchResultsController;
        searchResultsController.tableView.delegate = self;
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
        self.searchBar = self.searchController.searchBar; // join the searchBar of the current VC to be that of the
                                // UISearchController
        
        // sets up the search bar the set its apperance
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        [RUAppearance applyAppearanceToSearchBar:self.searchBar]; // set up the searchBar with proper name etc.
        
        // set up serch controller
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

/*
    set up the tvc with the data source and register the table view with the data source
 
 */
-(void)setupTableView:(UITableView *)tableView withDataSource:(DataSource *)dataSource{
    tableView.dataSource = dataSource;
    [dataSource registerReusableViewsWithTableView:tableView];
    [tableView reloadData];
}

/*
    Obtain the search table view to display , based on ios version
 
 */
-(UITableView *)searchTableView{
    if (!self.isViewLoaded) return nil;
    if (self.searchController) return self.searchResultsController.tableView; // for ios > 8
    else return self.mySearchDisplayController.searchResultsTableView; // lower versions
}

#pragma Mark - Searching
 #pragma mark - SearchDisplayController Delegate

/*
    The updating of the data being displayed is done based on a timer , this timer is reset when a search is done 
    based on the updateTime..forKey... func
 */
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self updateTimersForKeyPress]; // update the timer
    return NO;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    [self updateTimersForKeyPress];
}

/*
    There seems to be two timers that are used to maintain the proper updating of the results , 
    minSearchTimer and maxSearchTimer with two seperate time intervals to update the data
 
    On reaching the time , they both call the searchTimerFired func
 
 */

-(void)updateTimersForKeyPress{
    [self.minSearchTimer invalidate];
    self.minSearchTimer = nil;
    
    // s
    self.minSearchTimer = [NSTimer scheduledTimerWithTimeInterval:MIN_SEARCH_DELAY target:self selector:@selector(searchTimerFired) userInfo:nil repeats:NO];
    if (!self.maxSearchTimer) {
        self.maxSearchTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_SEARCH_DELAY target:self selector:@selector(searchTimerFired) userInfo:nil repeats:NO];
    }
}

/*
    Function is called when the timer ends and does the serach within the search data ce
 
 */
-(void)searchTimerFired{
    if (self.searchController) { // for ios > 8
        DataSource *dataSource = self.searchResultsController.dataSource; // <q> who runs the search ?
        if ([dataSource conformsToProtocol:@protocol(SearchDataSource)]) {
            DataSource<SearchDataSource> *searchDataSource = (DataSource<SearchDataSource>*)dataSource;
            // this does the search with the string
            [searchDataSource updateForQuery:self.searchBar.text]; // func within the data source
        }
    } else {
        [self.searchDataSource updateForQuery:self.searchBar.text];
    }
    
    [self invalidateSearchTimers]; // end both the serach timers after the query has been done
}

// ends the timers
-(void)invalidateSearchTimers{
    [self.minSearchTimer invalidate];
    self.minSearchTimer = nil;
    [self.maxSearchTimer invalidate];
    self.maxSearchTimer = nil;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [self presentSearch]; // func to display the serach VC
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
        [self.searchDataSource resetContent]; // reset the content after the search ??? may be for the next search ?
    }];
}

/*
    on searching the top bar of the navigation controller is hidden and the the color of the status 
    bar is changed from red to light / tranparent to show the search bars' upper portion
 
*/
-(void)setStatusAppearanceForSearchingState:(BOOL)searching{
    id navigationController = self.navigationController;
    if ([navigationController isKindOfClass:[RUNavigationController class]]) {
        RUNavigationController *navController = navigationController;
        navController.preferredStatusBarStyle = (searching ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent);
    }
}

/*
    what does this do ? <q>
    
    hides the serach controller and stores the serch query
 */
-(void)pushSearching{
    self.wasSearching = YES;
    self.lastSearchQuery = self.searchController.searchBar.text;
    self.searchController.active = NO;
}

/*
    <q>
    shows the searchController and with the last queru in the serachBar text
 
 */
-(void)popSearching{
    self.wasSearching = NO;
    self.searchController.active = YES;
    self.searchController.searchBar.text = self.lastSearchQuery;
    self.lastSearchQuery = nil;
}

#pragma mark - TableView Delegate

/*
    Store the touches in analytics
 */
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[RUAnalyticsManager sharedManager] queueEventForUserInteraction:[self userInteractionForTableView:tableView rowAtIndexPath:indexPath]];
    return indexPath;
}

/*
    returns information about the user interaction , about where it occured and at what row. Reader header file
 */
-(NSDictionary *)userInteractionForTableView:(UITableView *)tableView rowAtIndexPath:(NSIndexPath *)indexPath{
    return @{@"indexPath" : indexPath.description,
             @"description" : [[[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath] description]? : @"null"};
}

/*
    stores the heigh of the section <q>
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self dataSourceForTableView:tableView] tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self dataSourceForTableView:tableView] tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

/*
    highlights the row at index path ? <q>
 
    if the user touches the activity indicator of the place holder cell then do not highlight it , 
    but otherwise high light the cell, may be used when the used touches the cell ?
 
 */
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ALPlaceholderCell class]] || [cell isKindOfClass:[ALActivityIndicatorCell class]]) return NO;
    return YES;
}

#pragma mark - Data Source Delegate

/*
    decides the animation of the cell that is inserted or removed .

    <q>
        But why set it up , is it instead being used when the view is initially displayed
 */

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

/*
    Funcs to add and remove rows
    move rows
 */
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

/*
    reafresh sections , add remove and move section
 
 */

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



/*
    make the table view display the updated data source
 */

-(void)dataSourceDidReloadData:(DataSource *)dataSource direction:(DataSourceAnimationDirection)direction{
    UITableView *tableView = [self tableViewForDataSource:dataSource];
    [tableView reloadData];
    // set up animation to add the table view items <q> ?????
    if (direction != DataSourceAnimationDirectionNone) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:(direction == DataSourceAnimationDirectionLeft) ? kCATransitionFromRight : kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.1 :0 :0.2 :1]];
        [animation setDuration:0.55];
        [[tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    }
}

/*
    What is particular of Batch Updating ?
    Are multple items updated together ?
*/
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

/*
 
    update the data when the user pull to refresh
 */
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
