//
//  DataSource.m
//  
//
//  Created by Kyle Bailey on 6/24/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//


/*
    How is Data Source Used ? <q>
            >  It the view Data source which acts as an interface between all the specific class data source and the view controller that displayes the
                data.
            > It is like an abstract class
 
     <q> 
        Basic Picture of Data Source understood
 */


#import "DataSource_Private.h"
#import "AAPLPlaceholderView.h"
#import "NSObject+KVOBlock.h"
#import "UIView+LayoutSize.h"
#import <libkern/OSAtomic.h>
#import "ALTableViewAbstractCell.h"
#import "RowHeightCache.h"
#import "AAPLPlaceholderView.h"
#import "NSIndexPath+RowExtensions.h"

#import "ComposedDataSource.h"
#import <AFNetworkReachabilityManager.h>
#import "RUAnalyticsManager.h"
#import "SearchDataSource.h"

@interface DataSource () <AAPLStateMachineDelegate>
@property (nonatomic, strong) AAPLLoadableContentStateMachine *stateMachine;

@property (nonatomic, copy) dispatch_block_t whenLoadedBlock;

@property (nonatomic) BOOL loadingComplete;
@property (nonatomic, weak) AAPLLoading *loadingInstance;

@property (nonatomic) NSMutableDictionary *sizingCells;
@property (nonatomic) RowHeightCache *rowHeightCache;
@property (nonatomic) AAPLPlaceholderView *placeholderView;
@end

@implementation DataSource
@synthesize loadingError = _loadingError;


/*
    Called from the tableViewController to set up the data source
    
    initially only set up the error place holder cell contents .
    Set up notification , to be called when the information is avalible using the reachabilityDidChange function
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sizingCells = [NSMutableDictionary dictionary];
        self.rowHeightCache = [[RowHeightCache alloc] init];
        
        self.noContentTitle = @"No content available";
        self.errorTitle = @"Network error";
        self.errorMessage = @"Please check your network connection and try again";
        self.errorButtonTitle = @"Retry";
        
        __weak typeof(self) weakSelf = self;  // Prevent cycles ...
        self.errorButtonAction = ^{
            [weakSelf setNeedsLoadContent];
        };
        
        // sets up a notification for func to be called when server data is obtained.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

// detached from the Notification Center
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/*
    if the network is avalibale and the an error has occured while loading the content , then we load the content again. 
    Also ensure that the current class is a dataSource
 */
-(void)reachabilityDidChange:(NSNotification *)notification{
    if ([AFNetworkReachabilityManager sharedManager].reachable && self.isRootDataSource && [self.loadingState isEqualToString:AAPLLoadStateError]) {
        [self setNeedsLoadContent];
    }
}

// determine if the current class is a data source
- (BOOL)isRootDataSource
{
    return [self.delegate isKindOfClass:[DataSource class]] ? NO : YES;
}
// if the data source can be searched
- (BOOL)isSearchDataSource{
    return [self conformsToProtocol:@protocol(SearchDataSource)] ? YES : NO;
}

// description about the class .. <q> how is this used ?
-(NSString *)description{
    return [[super description] stringByAppendingFormat:@"\t%@",self.title];
}

#pragma mark - Data Source Implementation
// initially only a single section and 0 item . If there is an error then the place holder is shown
-(NSInteger)numberOfSections{
    if (self.showingPlaceholder) return 1;
    return 1;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    if (self.showingPlaceholder) return 1;
    return 0;
}

/*
    Define the abstract fucntions to be implemented by the sub classes that use this function
 */

/// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
- (NSArray *)indexPathsForItem:(id)object
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}

- (NSArray *)indexPathsForTitle:(id)title
{
     NSAssert(NO, @"Should be implemented by subclasses");
    return nil;   
}

/// Find the item at the specified index path.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}

/*
    Handles the common step of setting up the cells to be reused to prevent the cells from having to be recreated each step.
 */
-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    // What is the purpose of using AL... class ? Is something being added ? or is it handling something ios did not have in older versions ? <q>
    // Seems to be used for unique customization of the cell within the tableViewContr...
    // AL.... inherits from UIView
    [tableView registerClass:[ALPlaceholderCell class] forCellReuseIdentifier:NSStringFromClass([ALPlaceholderCell class])];
    
    [tableView registerClass:[ALActivityIndicatorCell class] forCellReuseIdentifier:NSStringFromClass([ALActivityIndicatorCell class])];
    
   /*
        <q> 
            > AL... inherits from UITabBarController , so is it handling the UITabBar ??? or is is used for cell customization ???
    */
}

/*
    <q> What is the purpose of chaching heights ? They are single values ?
        No , different types of information have different heights. 
            say a route or a stop , or a news item .
 */
#pragma mark - Cached Heights
-(void)invalidateCachedHeights{
    [self.rowHeightCache invalidateCachedHeights];
}
-(void)invalidateCachedHeightsForSection:(NSInteger)section{
    [self.rowHeightCache invalidateCachedHeightsForSection:section];
}
-(void)invalidateCachedHeightsForIndexPaths:(NSArray *)indexPaths{
    [self.rowHeightCache invalidateCachedHeightsForIndexPaths:indexPaths];
}


/*
    Sets up the function to enable the table view to access the data source and display the items properly
 
 */
#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.numberOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self numberOfItemsInSection:section];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return (section == 0) ? self.title : nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return (section == 0) ? self.footer : nil;
}

-(BOOL)tableView:(UITableView *)tableView sectionHasCustomHeader:(NSInteger)section{
    return NO;
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

/*
    Obtain the reuse cell for the place holder
 
 
    Based on the ability to load the state or not , he determine the type of cell to be displayed . 
    ALActivityIndi...Cell ->
 */
-(NSString *)placeholderReuseIdentifier{
    return [self.loadingState isEqualToString:AAPLLoadStateLoadingContent] ? NSStringFromClass([ALActivityIndicatorCell class]) : NSStringFromClass([ALPlaceholderCell class]);
}

/*
    To configure the cell if required to be implemented by the subclass that need this functionality
 */
-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

/*
    If an error has occured while trying to show the data , then we show the user the place holder ...
    If the information is still being loaded , then we show them the activity indication
    
    The type of configuration to be choosen is determine the way the user of the fucntion sets up the cell , 
    if the cell is of place holder time, then set up a place holder , 
    else if the cell is of indicator type , then animate and show the indicator icon
 */
// Error loading Data ?
-(void)configurePlaceholderCell:(id)cell{
    if ([cell isKindOfClass:[ALPlaceholderCell class]]) {
        ALPlaceholderCell *placeholder = cell;
        if ([self.loadingState isEqualToString:AAPLLoadStateError]) {
            placeholder.title = self.errorTitle;
            placeholder.message = self.errorMessage;
            placeholder.image = self.errorImage;
            placeholder.buttonTitle = self.errorButtonTitle;
            placeholder.buttonAction = self.errorButtonAction;
        } else {
            placeholder.title = self.noContentTitle;
            placeholder.message = self.noContentMessage;
            placeholder.image = self.noContentImage;
            placeholder.buttonTitle = nil;
            placeholder.buttonAction = nil;
        }
    } else if ([cell isKindOfClass:[ALActivityIndicatorCell class]]) {
        ALActivityIndicatorCell *activity = cell;
        [activity.activityIndicatorView startAnimating];
    }
}

/*
    Is this removing the cell from use ? Unclear
 
 */
-(id)tableView:(UITableView *)tableView sizingCellWithIdentifier:(NSString *)identifier{
    id cell = self.sizingCells[identifier];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [cell removeFromSuperview];
        self.sizingCells[identifier] = cell;
    }
    return cell;
}

/*
 
 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewAbstractCell *cell; // an abstract cell with minimal configurations
    
    if (self.showingPlaceholder) {
        // set up the place holder cell
        cell = [tableView dequeueReusableCellWithIdentifier:[self placeholderReuseIdentifier]];
        [cell updateFonts]; // the update fonts is called on the sub classes , so the configuration is done by specific classes
        [self configurePlaceholderCell:(ALPlaceholderCell *)cell];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierForRowAtIndexPath:indexPath]];
        [cell updateFonts];
        [self configureCell:cell forRowAtIndexPath:indexPath];
    }

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

/*
    Height is stored , try to resue it ? <q>
    
        Height needs to be distinguished becase there are 3 different types : 
            > PlaceHolder Error Cell Has higher height
            > Route and Stop have different heights
 
    The reason for cache the heighs is the way that heights are obtained : 
        To obtain the height , an acutal cell with the configuations of a specific class is created and then this
        cell is used to determine the height of the celll at that particuular index path
    
    Is there a more efficient way to obtain the height : Possible method would be using the measurement of the subview
 */

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *cachedHeight = [self.rowHeightCache cachedHeightForRowAtIndexPath:indexPath];
    
    /*
    static volatile int64_t hits = 0;
    static volatile int64_t misses = 0;

    cachedHeight ? hits++ : misses++;
    
    if (((hits + misses) % 20) == 0) {
        NSLog(@"Hits: %lld, Misses: %lld, Rate: %f per cent",hits,misses,((CGFloat)hits/(hits+misses))*100.0);
    }*/

    if (cachedHeight) return [cachedHeight doubleValue];
    
    
    // Create a cell with the specific configurations
    ALTableViewAbstractCell *cell;
    
    if (self.showingPlaceholder) {  // Place Holder Text is set if there is no input Connection
        ALPlaceholderCell *placeholderCell = [self tableView:tableView sizingCellWithIdentifier:[self placeholderReuseIdentifier]];
        cell = placeholderCell;
        [cell updateFonts];
        [self configurePlaceholderCell:placeholderCell];
    } else {
        cell = [self tableView:tableView sizingCellWithIdentifier:[self reuseIdentifierForRowAtIndexPath:indexPath]];
        [cell updateFonts];
        [self configureCell:cell forRowAtIndexPath:indexPath];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
   
    // obtain the height from the cell
    CGFloat height = [cell layoutSizeFittingSize:tableView.bounds.size].height;
    
    // cache the height from the created cell for more efficient reuse
    [self.rowHeightCache setCachedHeight:height forRowAtIndexPath:indexPath];
    
    return height;
}

/*
    Estimated height ?
        <q> How is the height being estimated ?
 */
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *cachedHeight = [self.rowHeightCache cachedHeightForRowAtIndexPath:indexPath];
    if (cachedHeight) return [cachedHeight doubleValue];
    return tableView.estimatedRowHeight; // default set up by apple is 0 <q> how is this changed ?
}

/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (![self tableView:tableView sectionHasCustomHeader:section]) return UITableViewAutomaticDimension;
    
    UIView *view = [self tableView:tableView viewForHeaderInSection:section];
    [view setNeedsUpdateConstraints];
    [view updateConstraintsIfNeeded];
    
    return [view layoutSizeFittingWidth:CGRectGetWidth(tableView.bounds)].height;
}*/

/*
    The data source also supports collection view
        Functions for the collection view to obtain information from the Data Source
 */

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifierForItemAtIndexPath:indexPath] forIndexPath:indexPath];
    
   // [cell updateFonts];
    [self configureCell:cell forItemAtIndexPath:indexPath];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

-(void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView{

}

-(NSString *)reuseIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(void)configureCell:(id)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

/*
    Functions which load the content for the data source ? 
        <q> 
            Are they handled by the sub classes or are they handled by the generic data source ?
                 > Handled by the sub classes .
 
 */

#pragma mark - ContentLoading methods

/*
    What is the function of the state Mahine ? 
        May be to define states where the user tries to access information from the internet , or when the request has resulted in an error , 
        or may be to specify the state when the user request is still going on ?
 
    It seems the diffrent possible states are 
 
 
     NSString * const AAPLLoadStateInitial = @"Initial";
     NSString * const AAPLLoadStateLoadingContent = @"LoadingState";
     NSString * const AAPLLoadStateRefreshingContent = @"RefreshingState";
     NSString * const AAPLLoadStateContentLoaded = @"LoadedState";
     NSString * const AAPLLoadStateNoContent = @"NoContentState";
     NSString * const AAPLLoadStateError = @"ErrorState";
    
    The state machine in implemented in the APPLContentLoading.m file and APPLStateMachine file

 */

- (AAPLLoadableContentStateMachine *)stateMachine
{
    if (_stateMachine)
        return _stateMachine;
    
    _stateMachine = [[AAPLLoadableContentStateMachine alloc] init];
    _stateMachine.delegate = self;
    return _stateMachine;
}

/*
    Returns the current state from the Apple State Machien
 
 */
- (NSString *)loadingState
{
    // Don't cause the creation of the state machine just by inspection of the loading state.
    if (!_stateMachine)
        return AAPLLoadStateInitial;
    return _stateMachine.currentState;
}

/*
    Change the state of the state machine into the required state
 */
- (void)setLoadingState:(NSString *)loadingState
{
    AAPLLoadableContentStateMachine *stateMachine = self.stateMachine;
    if (loadingState != stateMachine.currentState)
        stateMachine.currentState = loadingState;
}

/*
    <q> Begin loading information ?
 
    No this function only sets up the state machine , the loading corresponding to the state is done by another class
    using the notifyWillLoadContent
 */
- (void)beginLoading
{
    self.loadingComplete = NO;
    self.loadingState = (([self.loadingState isEqualToString:AAPLLoadStateInitial] || [self.loadingState isEqualToString:AAPLLoadStateLoadingContent] || [self.loadingState isEqualToString:AAPLLoadStateError]) ? AAPLLoadStateLoadingContent : AAPLLoadStateRefreshingContent);
    
    [self notifyWillLoadContent];
}
/*
    <q> How is this function used ?
    Error state ?
    Not exclusively for error state , but notifies someone about the error ????
 */
- (void)endLoadingWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
    self.loadingError = error;
    self.loadingState = state;
    
    if (error) [[RUAnalyticsManager sharedManager] queueEventForError:error];
    
    [self notifyBatchUpdate:^{
        if (update)
            update();
    }];
    
    self.loadingComplete = YES;
    if (self.whenLoadedBlock) {
        self.whenLoadedBlock();
        self.whenLoadedBlock = nil;
    }
    [self notifyContentLoadedWithError:error];
}

/*
    Cancels the previous request to load content and starts the load again
 
 */
- (void)setNeedsLoadContent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadContent) object:nil];
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0];
}

- (void)resetContent
{
    _stateMachine = nil;
    // Content has been reset, if we're loading something, chances are we don't need it.
    self.loadingInstance.current = NO;
}

- (void)loadContent
{
    // To be implemented by subclasses…
}

- (void)loadContentWithBlock:(AAPLLoadingBlock)block
{
    [self beginLoading];
    
    __weak typeof(self) weakself = self;
    
    AAPLLoading *loading = [AAPLLoading loadingWithCompletionHandler:^(NSString *newState, NSError *error, AAPLLoadingUpdateBlock update){
        if (!newState)
            return;
        
        [self endLoadingWithState:newState error:error update:^{
            DataSource *me = weakself;
            if (update && me)
                update(me);
        }];
    }];
    
    // Tell previous loading instance it's no longer current and remember this loading instance
    self.loadingInstance.current = NO;
    self.loadingInstance = loading;
    
    // Call the provided block to actually do the load
    block(loading); // block is actually a fuction pointer which takes AAPLLoading as its input
}

/*
    Execute block on ending loading
 */
- (void)whenLoaded:(dispatch_block_t)block
{
    if (self.whenLoadedBlock) {
        dispatch_block_t currentBlock = self.whenLoadedBlock;
        self.whenLoadedBlock = ^{
            currentBlock();
            block();
        };
    }
    
    if (self.loadingComplete && self.whenLoadedBlock) {
        self.whenLoadedBlock();
        self.whenLoadedBlock = nil;
    }
}


// State change is not KVC , and the KVO is not notified , so we have to use thses functions
- (void)stateWillChange
{
    // loadingState property isn't really Key Value Compliant, so let's begin a change notification
    [self willChangeValueForKey:@"loadingState"];
}

- (void)stateDidChange
{
    // loadingState property isn't really Key Value Compliant, so let's finish a change notification
    [self didChangeValueForKey:@"loadingState"];
}

- (void)didEnterLoadingState
{
    [self updatePlaceholderState];
}

- (void)didEnterLoadedState
{
    [self updatePlaceholderState];
}

- (void)didEnterNoContentState
{
    [self updatePlaceholderState];
}

- (void)didEnterErrorState
{
    [self updatePlaceholderState];
}

#pragma mark - Placeholder

- (BOOL)shouldDisplayPlaceholder
{
    NSString *loadingState = self.loadingState;
    
    // If we're in the error state & have an error message or title
    if ([loadingState isEqualToString:AAPLLoadStateError] && (self.errorMessage || self.errorTitle))
        return YES;
    
    // Only display a placeholder when we're loading or have no content
    if (![loadingState isEqualToString:AAPLLoadStateLoadingContent] && ![loadingState isEqualToString:AAPLLoadStateNoContent])
        return NO;
    
    return YES;
}

- (void)updatePlaceholderState{
    self.showingPlaceholder = self.shouldDisplayPlaceholder;
}

/*
    <q> What is being done here ?
 
 */
-(void)setShowingPlaceholder:(BOOL)showingPlaceholder{
    if (_showingPlaceholder == showingPlaceholder) { // if we are already doing what is required
        if (showingPlaceholder) { // if we want to display a place holder , we remove chache and refresh ?
            [self invalidateCachedHeightsForIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
            [self notifyItemsRefreshedAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
        }
    } else { // if the required state and current state of place holder being displayed or not is differetn then
        [self invalidateCachedHeights];
        [self notifyBatchUpdate:^{ // simply execute this block , either by the subclasses or by the current class itself
            
            // Keep track of the changes in sections and the items present in the sections
            NSInteger oldNumberOfSections = self.numberOfSections;
            NSInteger oldNumberOfItemsInFirstSection = [self numberOfItemsInSection:0];
            
            _showingPlaceholder = showingPlaceholder;
            
            NSInteger newNumberOfSections = self.numberOfSections;
            NSInteger newNumberOfItemsInFirstSection = [self numberOfItemsInSection:0];
            
            // If the number of sections is not zero , then notify
            if (newNumberOfSections > 0 && oldNumberOfSections > 0) {
                // nofity about the removal and insertion of section and add animations for the actiosn
                [self notifyItemsRemovedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, oldNumberOfItemsInFirstSection) inSection:0]];
                [self notifyItemsInsertedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, newNumberOfItemsInFirstSection) inSection:0]];
                [self notifySectionsInserted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, newNumberOfSections-1)]];
                [self notifySectionsRemoved:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, oldNumberOfSections-1)]];
            } else {
                [self notifySectionsInserted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)]];
                [self notifySectionsRemoved:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldNumberOfSections)]];
            }
        }];
    }
}

#pragma mark - Data Source Delegate
// Use these methods to notify the observers of changes to the dataSource.
// and show animations for the removal
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths{
    [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths direction:DataSourceAnimationDirectionNone];
}

- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths{
    [self notifyItemsRemovedAtIndexPaths:removedIndexPaths direction:DataSourceAnimationDirectionNone];
}

- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths{
    [self notifyItemsRefreshedAtIndexPaths:refreshedIndexPaths direction:DataSourceAnimationDirectionNone];
}

// Use these methods to notify the observers of changes to the dataSource.
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertItemsAtIndexPaths:direction:)]) {
        [delegate dataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths direction:direction];
    }
    
}

/*
    remove the items and shows its animation
 */
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveItemsAtIndexPaths:direction:)]) {
        [delegate dataSource:self didRemoveItemsAtIndexPaths:removedIndexPaths direction:direction];
    }
    
}

- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshItemsAtIndexPaths:direction:)]) {
        [delegate dataSource:self didRefreshItemsAtIndexPaths:refreshedIndexPaths direction:direction];
    }
    
}

- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveItemFromIndexPath:toIndexPath:)]) {
        [delegate dataSource:self didMoveItemFromIndexPath:indexPath toIndexPath:newIndexPath];
    }
    
}
/*
    Remove / insert sections and show animation
 */
- (void)notifySectionsInserted:(NSIndexSet *)sections{
    [self notifySectionsInserted:sections direction:DataSourceAnimationDirectionNone];
}

- (void)notifySectionsRemoved:(NSIndexSet *)sections{
    [self notifySectionsRemoved:sections direction:DataSourceAnimationDirectionNone];
}

- (void)notifySectionsRefreshed:(NSIndexSet *)sections{
    [self notifySectionsRefreshed:sections direction:DataSourceAnimationDirectionNone];
}

- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection{
    ASSERT_MAIN_THREAD;
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveSection:toSection:)]) {
        [delegate dataSource:self didMoveSection:section toSection:newSection];
    }
}

/*
    Nofity the sub classes that a section has been inserted and call the required functions
 */
- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertSections:direction:)]) {
        [delegate dataSource:self didInsertSections:sections direction:direction];
    }
}
/*
    Notify the sub classes about the section removal
 */
- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveSections:direction:)]) {
        [delegate dataSource:self didRemoveSections:sections direction:direction];
    }
}

/*
    Notify the sub classes about the section refresh
 */
- (void)notifySectionsRefreshed:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshSections:direction:)]) {
        [delegate dataSource:self didRefreshSections:sections direction:direction];
    }
    
}

-(void)notifyDidReloadData{
    [self notifyDidReloadDataWithDirection:DataSourceAnimationDirectionNone];
}

/*
    Notify the sub classes about the section relaod data ????
 */
- (void)notifyDidReloadDataWithDirection:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidReloadData:direction:)]) {
        [delegate dataSourceDidReloadData:self direction:direction];
    }
}

- (void)notifyBatchUpdate:(dispatch_block_t)update
{
    [self notifyBatchUpdate:update complete:nil];
}

/*
    The block is executed either by the subclass or by the data source itself
    The function simply executes the update block and then the complete block
 */
- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:performBatchUpdate:complete:)]) {
        // execute the blocks in the sub classes
        [delegate dataSource:self performBatchUpdate:update complete:complete];
                // performBatchUpdate is implemented by the subclasses
    }
    else {
        // execute the block wiith the data source class
        if (update) {
            update();
        }
        if (complete) {
            complete();
        }
    }
}

// Functions handled by the subclasses
- (void)notifyContentLoadedWithError:(NSError *)error{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didLoadContentWithError:)]) {
        [delegate dataSource:self didLoadContentWithError:error];
    }
}

/*
    The data source
 */
- (void)notifyWillLoadContent{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceWillLoadContent:)]) {
        [delegate dataSourceWillLoadContent:self];
    }
}

@end

