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
#import "RUAnalyticsManager.h"
#import "SearchDataSource.h"

@interface DataSource () <AAPLStateMachineDelegate>

@property (nonatomic, copy) dispatch_block_t whenLoadedBlock;

@property (nonatomic) BOOL loadingComplete;
@property (nonatomic, weak) AAPLLoading *loadingInstance;

// STore the cache heighs of the cells
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
    if (self)
    {
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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/*
    if the network is avalibale and the an error has occured while loading the content , then we load the content again. 
    Also ensure that the current class is a dataSource
 */
-(void)reachabilityDidChange:(NSNotification *)notification
{
    // if data is reachable , if data can be send down to lower level classes and the previous load ended in an error
    //          then realod the data
    if ([AFNetworkReachabilityManager sharedManager].reachable && self.isRootDataSource && [self.loadingState isEqualToString:AAPLLoadStateError])
    {
        [self setNeedsLoadContent];
    }
}

/*
    How to determine if the data source is the root ?
    if it is a root data source 's delegate is a data source , then it is not a root ,  
    else it is a root..
 */
- (BOOL)isRootDataSource
{
    return [self.delegate isKindOfClass:[DataSource class]] ? NO : YES;
}
// if the data source can be searched
- (BOOL)isSearchDataSource
{
    return [self conformsToProtocol:@protocol(SearchDataSource)] ? YES : NO;
}

// description about the class ..
// used for analytics etc
-(NSString *)description
{
    return [[super description] stringByAppendingFormat:@"\t%@",self.title];
}


#pragma mark - Data Source Implementation
// initially only a single section and 0 item . If there is an error then the place holder is shown
-(NSInteger)numberOfSections
{
    if (self.showingPlaceholder) return 1;
    return 1;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section
{
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
- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}

/*
    Handles the common step of setting up the cells to be reused to prevent the cells from having to be recreated each step.
 */
-(void)registerReusableViewsWithTableView:(UITableView *)tableView
{
    // Seems to be used for unique customization of the cell within the tableViewContr...
    [tableView registerClass:[ALPlaceholderCell class] forCellReuseIdentifier:NSStringFromClass([ALPlaceholderCell class])];
    
    [tableView registerClass:[ALActivityIndicatorCell class] forCellReuseIdentifier:NSStringFromClass([ALActivityIndicatorCell class])];
    
}

/*
 
        different types of information have different heights.
            say a route or a stop , or a news item .
 */
#pragma mark - Cached Heights
-(void)invalidateCachedHeights
{
    [self.rowHeightCache invalidateCachedHeights];
}
-(void)invalidateCachedHeightsForSection:(NSInteger)section
{
    [self.rowHeightCache invalidateCachedHeightsForSection:section];
}
-(void)invalidateCachedHeightsForIndexPaths:(NSArray *)indexPaths
{
    [self.rowHeightCache invalidateCachedHeightsForIndexPaths:indexPaths];
}


/*
    Sets up the function to enable the table view to access the data source and display the items properly
 
 */
#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? self.title : nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return (section == 0) ? self.footer : nil;
}

-(BOOL)tableView:(UITableView *)tableView sectionHasCustomHeader:(NSInteger)section
{
    return NO;
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

/*
    Obtain the reuse cell for the place holder
 
    Based on the ability to load the state or not , he determine the type of cell to be displayed .
    ALActivityIndi...Cell ->
    
    if the data is being loaded , show the indicaltor cell , else the place holder
 
 */
-(NSString *)placeholderReuseIdentifier
{
    return [self.loadingState isEqualToString:AAPLLoadStateLoadingContent] ? NSStringFromClass([ALActivityIndicatorCell class]) : NSStringFromClass([ALPlaceholderCell class]);
}

/*
    To configure the cell if required to be implemented by the subclass that need this functionality
    Implemented by the sub classes
 */
-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/*
    If an error has occured while trying to show the data , then we show the user the place holder ...
    If the information is still being loaded , then we show them the activity indication
    
    The type of configuration to be choosen is determine the way the user of the fucntion sets up the cell , 
    if the cell is of place holder time, then set up a place holder , 
    else if the cell is of indicator type , then animate and show the indicator icon
 */
// Error loading Data ?
-(void)configurePlaceholderCell:(id)cell
{
    if ([cell isKindOfClass:[ALPlaceholderCell class]])
    {
        ALPlaceholderCell *placeholder = cell;
        // if an error in loading has occured , then show the error info in the place holder
        if ([self.loadingState isEqualToString:AAPLLoadStateError])
        {
            placeholder.title = self.errorTitle;
            placeholder.message = self.errorMessage;
            placeholder.image = self.errorImage;
            placeholder.buttonTitle = self.errorButtonTitle;
            placeholder.buttonAction = self.errorButtonAction;
        }
        else // if no content has been loaded from the servers then , how the no content place holder
        {
            placeholder.title = self.noContentTitle;
            placeholder.message = self.noContentMessage;
            placeholder.image = self.noContentImage;
            placeholder.buttonTitle = nil;
            placeholder.buttonAction = nil;
        }
        
    }
    else if ([cell isKindOfClass:[ALActivityIndicatorCell class]]) // if the cell is an acitivcity indicator cell , then show the indicator..
    {
        ALActivityIndicatorCell *activity = cell;
        [activity.activityIndicatorView startAnimating]; 
    }
}

/*
    Is this removing the cell from use ? Unclear
 */
-(id)tableView:(UITableView *)tableView sizingCellWithIdentifier:(NSString *)identifier
{
    id cell = self.sizingCells[identifier];
    if (!cell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [cell removeFromSuperview];
        self.sizingCells[identifier] = cell;
    }
    return cell;
}

/*
    This proviees the cells to be displayed in the table view .. 
    the configurations are done by the sub classes which use the configure cell function
 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALTableViewAbstractCell *cell; // an abstract cell with minimal configurations
    
    if (self.showingPlaceholder)
    {
        // set up the place holder cell
        cell = [tableView dequeueReusableCellWithIdentifier:[self placeholderReuseIdentifier]];
        [cell updateFonts]; // the update fonts is called on the sub classes , so the configuration is done by specific classes
        [self configurePlaceholderCell:(ALPlaceholderCell *)cell];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierForRowAtIndexPath:indexPath]];
        [cell updateFonts];
        [self configureCell:cell forRowAtIndexPath:indexPath]; // configured by the sub classes
    }

    // look at the changed contraints
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *cachedHeight = [self.rowHeightCache cachedHeightForRowAtIndexPath:indexPath];
    
    /*
    static volatile int64_t hits = 0;
    static volatile int64_t misses = 0;

    cachedHeight ? hits++ : misses++;
    
    if (((hits + misses) % 20) == 0) {
        NSLog(@"Hits: %lld, Misses: %lld, Rate: %f per cent",hits,misses,((CGFloat)hits/(hits+misses))*100.0);
    }*/

    if (cachedHeight) return [cachedHeight doubleValue];
    
    /*
        The row height is calculted from the constraints.
            But crreating the cell and calculating the height for each time the user moves up and down is very expensive.
        So we store the heights which have already been calculated from the contraints and give them to the table view..
        
            If the height for the cell has not been calculated previously , then we try again...

     */
    
    
    // Create a cell with the specific configurations
    ALTableViewAbstractCell *cell;
    
    if (self.showingPlaceholder)
    {
        // Place Holder Text is set if there is no input Connection
        ALPlaceholderCell *placeholderCell = [self tableView:tableView sizingCellWithIdentifier:[self placeholderReuseIdentifier]];
        cell = placeholderCell;
        [cell updateFonts];
        [self configurePlaceholderCell:placeholderCell];
    }
    else
    {
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
 */
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *cachedHeight = [self.rowHeightCache cachedHeightForRowAtIndexPath:indexPath]; // the estimiated height is obtained from craeting the cell , applying constrains and then reading the cell's height
    
    if (cachedHeight)
        return [cachedHeight doubleValue];
    
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifierForItemAtIndexPath:indexPath] forIndexPath:indexPath];
   // [cell updateFonts];
    [self configureCell:cell forItemAtIndexPath:indexPath];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

-(void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{

}

-(NSString *)reuseIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(void)configureCell:(id)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
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
 
    It is based on this state machine that the data is obtained from the server : 
 
 
 
 */

// create the state machine
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
    If the machine has not been created , then the loading state is give..

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

- (void)beginLoading
{
    self.loadingComplete = NO;
    /*
        If the loading state is initiali , or is in the process of laoding content , or if an error occured , then we change the state to be the loading content state .. 
        Else we are refreshing the content
     
     */
    self.loadingState = (([self.loadingState isEqualToString:AAPLLoadStateInitial] || [self.loadingState isEqualToString:AAPLLoadStateLoadingContent] || [self.loadingState isEqualToString:AAPLLoadStateError]) ? AAPLLoadStateLoadingContent : AAPLLoadStateRefreshingContent);
    
    [self notifyWillLoadContent];
}
/*
    <q> How is this function used ?
 */
- (void)endLoadingWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
    self.loadingError = error;
    self.loadingState = state;
    
    if (error) [[RUAnalyticsManager sharedManager] queueEventForError:error];
   
    // update refers to the changes that have to be made to the data source or table view
    [self notifyBatchUpdate:^{
        if (update)
            update();
    }];
    
    self.loadingComplete = YES;
    
    if (self.whenLoadedBlock)
    {
        self.whenLoadedBlock();
        self.whenLoadedBlock = nil;
    }
    
    [self notifyContentLoadedWithError:error];
}

/*
    Cancels the previous request to load content and starts the load again
 
    Data souce calls load content on its sub classes ?
 */
- (void)setNeedsLoadContent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadContent) object:nil];
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0];
}

// reset the data machine
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

// conforms to APPLContentLoading Protocol
// AAPLLoadingBlock takes a APLLoading as a parameter. It might be used to know more about the state and change the state?
- (void)loadContentWithBlock:(AAPLLoadingBlock)block
{
    [self beginLoading];
    
    __weak typeof(self) weakself = self;
   
    // the
    AAPLLoading *loading = [AAPLLoading loadingWithCompletionHandler:^
    (NSString *newState, NSError *error, AAPLLoadingUpdateBlock update) // the update block is attached to the loading state
    {
        if (!newState)
            return;
        
        [self endLoadingWithState:newState error:error update:^
        {
            DataSource *me = weakself;
            if (update && me)
                update(me); // update the data source ? // update block takes in an id as parameter
        }];
    }];
    
    // Tell previous loading instance it's no longer current and remember this loading instance
    self.loadingInstance.current = NO;
    self.loadingInstance = loading;
    
    // Call the provided block to actually do the load
    block(loading); // block is actually a fuction pointer which takes AAPLLoading as its input
                    // the block might use the loading pointer to change the state based on the content loading state , wether completed , or on going etc..
    if(self.whenLoadedBlock)
    {
        self.whenLoadedBlock();
    }
}

/*
    Execute block on ending loading :: See header
 */
- (void)whenLoaded:(dispatch_block_t)block
{
    if (self.whenLoadedBlock)
    {
        // combine our new block with the old one
        dispatch_block_t currentBlock = self.whenLoadedBlock;
        self.whenLoadedBlock = ^
        {
            currentBlock();
            block();
        };
    } else {
        self.whenLoadedBlock = block;
    }

    // execute the whenLoadedBlock if we are done loading
    if (self.loadingComplete)
    {
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
    
    // If we're in the error state & have an error message or title we dispplay the placeholder
    if ([loadingState isEqualToString:AAPLLoadStateError] && (self.errorMessage || self.errorTitle))
        return YES;
    
    // Only display a placeholder when we're loading or have no content
    if (![loadingState isEqualToString:AAPLLoadStateLoadingContent] && ![loadingState isEqualToString:AAPLLoadStateNoContent])
        return NO;
    
    return YES;
}

- (void)updatePlaceholderState
{
    self.showingPlaceholder = self.shouldDisplayPlaceholder;
}

/*
 
 */
-(void)setShowingPlaceholder:(BOOL)showingPlaceholder
{
    if (_showingPlaceholder == showingPlaceholder) // if we have the place holder
    {
        // if we are already doing what is required
        if (showingPlaceholder)
        { // if we want to display a place holder , we remove chache and refrech the place hodler cell ?
            [self invalidateCachedHeightsForIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
            [self notifyItemsRefreshedAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
        }
    }
    else
    {
        // if the required state and current state of place holder being displayed or not is differetn then
        [self invalidateCachedHeights];
        [self notifyBatchUpdate:^
        { // simply execute this block , either by the subclasses or by the current class itself
            
            // Keep track of the changes in sections and the items present in the sections
            NSInteger oldNumberOfSections = self.numberOfSections;
            NSInteger oldNumberOfItemsInFirstSection = [self numberOfItemsInSection:0];
            
            _showingPlaceholder = showingPlaceholder;
            
            NSInteger newNumberOfSections = self.numberOfSections;
            NSInteger newNumberOfItemsInFirstSection = [self numberOfItemsInSection:0];
            
            // If the number of sections is not zero , then notify
            if (newNumberOfSections > 0 && oldNumberOfSections > 0)
            {
                // nofity about the removal and insertion of section and add animations for the actiosn
                [self notifyItemsRemovedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, oldNumberOfItemsInFirstSection) inSection:0]];
                [self notifyItemsInsertedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, newNumberOfItemsInFirstSection) inSection:0]];
                [self notifySectionsInserted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, newNumberOfSections-1)]];
                [self notifySectionsRemoved:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, oldNumberOfSections-1)]];
            }
            else
            {
                [self notifySectionsInserted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)]];
                [self notifySectionsRemoved:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldNumberOfSections)]];
            }
        }];
    }
}

#pragma mark - Data Source Delegate
// Use these methods to notify the observers of changes to the dataSource.
// and show animations for the removal
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths
{
    [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths direction:DataSourceAnimationDirectionNone];
}

- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths
{
    [self notifyItemsRemovedAtIndexPaths:removedIndexPaths direction:DataSourceAnimationDirectionNone];
}

- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths{
    [self notifyItemsRefreshedAtIndexPaths:refreshedIndexPaths direction:DataSourceAnimationDirectionNone];
}


/*
    Speficy the changes that happens in the data source , then the table view controller will mirror these changes and insert and remove according to the data source
 
 */


// Use these methods to notify the observers of changes to the dataSource.
// notify the table view controller , which is the delete of this data source about the changes..
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertItemsAtIndexPaths:direction:)])
    {
        [delegate dataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths direction:direction];
    }
}

/*
    remove the items and shows its animation
 */
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveItemsAtIndexPaths:direction:)])
    {
        [delegate dataSource:self didRemoveItemsAtIndexPaths:removedIndexPaths direction:direction];
    }
}

// reload the cells , with animation to notify the user of the change..
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimationDirection)direction
{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshItemsAtIndexPaths:direction:)])
    {
        [delegate dataSource:self didRefreshItemsAtIndexPaths:refreshedIndexPaths direction:direction];
    }
    
}

- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveItemFromIndexPath:toIndexPath:)]) {
        [delegate dataSource:self didMoveItemFromIndexPath:indexPath toIndexPath:newIndexPath];
    }
    
}
/*
    Remove / insert sections and show animation
 */
- (void)notifySectionsInserted:(NSIndexSet *)sections
{
    [self notifySectionsInserted:sections direction:DataSourceAnimationDirectionNone];
}

- (void)notifySectionsRemoved:(NSIndexSet *)sections
{
    [self notifySectionsRemoved:sections direction:DataSourceAnimationDirectionNone];
}

- (void)notifySectionsRefreshed:(NSIndexSet *)sections
{
    [self notifySectionsRefreshed:sections direction:DataSourceAnimationDirectionNone];
}

- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection
{
    ASSERT_MAIN_THREAD;
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveSection:toSection:)])
    {
        [delegate dataSource:self didMoveSection:section toSection:newSection];
    }
}

/*
    Nofity the sub classes that a section has been inserted and call the required functions
 */
- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertSections:direction:)])
    {
        [delegate dataSource:self didInsertSections:sections direction:direction];
    }
}
/*
    Notify the sub classes about the section removal
 */
- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveSections:direction:)])
    {
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

