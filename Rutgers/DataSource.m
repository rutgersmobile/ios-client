//
//  DataSource.m
//  
//
//  Created by Kyle Bailey on 6/24/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

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


@interface DataSource () <AAPLStateMachineDelegate>
@property (nonatomic, strong) AAPLLoadableContentStateMachine *stateMachine;

@property (nonatomic, copy) dispatch_block_t pendingUpdateBlock;
@property (nonatomic) BOOL loadingComplete;
@property (nonatomic, weak) AAPLLoading *loadingInstance;

@property (nonatomic) NSMutableDictionary *sizingCells;
@property (nonatomic) RowHeightCache *rowHeightCache;
@property (nonatomic) AAPLPlaceholderView *placeholderView;
@end

@implementation DataSource
@synthesize loadingError = _loadingError;

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
        
        __weak typeof(self) weakSelf = self;
        self.errorButtonAction = ^{
            [weakSelf setNeedsLoadContent];
        };
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reachabilityDidChange:(NSNotification *)notification{
    if ([AFNetworkReachabilityManager sharedManager].reachable && [self.loadingState isEqualToString:AAPLLoadStateError] && self.isRootDataSource) {
        [self setNeedsLoadContent];
    }
}

- (BOOL)isRootDataSource
{
    return [self.delegate isKindOfClass:[DataSource class]] ? NO : YES;
}

- (BOOL)isSearchDataSource{
    return [self conformsToProtocol:NSProtocolFromString(@"SearchDataSource")] ? YES : NO;
}

-(NSString *)description{
    return [[super description] stringByAppendingFormat:@"\t%@",self.title];
}

#pragma mark - Data Source Implementation
-(NSInteger)numberOfSections{
    if (self.showingPlaceholder) return 1;
    return 1;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    if (self.showingPlaceholder) return 1;
    return 0;
}

/// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
- (NSArray *)indexPathsForItem:(id)object
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}

/// Find the item at the specified index path.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [tableView registerClass:[ALPlaceholderCell class] forCellReuseIdentifier:NSStringFromClass([ALPlaceholderCell class])];
    [tableView registerClass:[ALActivityIndicatorCell class] forCellReuseIdentifier:NSStringFromClass([ALActivityIndicatorCell class])];
}

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

-(NSString *)placeholderReuseIdentifier{
    return [self.loadingState isEqualToString:AAPLLoadStateLoadingContent] ? NSStringFromClass([ALActivityIndicatorCell class]) : NSStringFromClass([ALPlaceholderCell class]);
}

-(id)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier{
    return [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)configurePlaceholderCell:(id)cell{
    if ([cell isKindOfClass:[ALPlaceholderCell class]]) {
        ALPlaceholderCell *placeholder = cell;
        if ([self.loadingState isEqualToString:AAPLLoadStateNoContent]) {
            placeholder.title = self.noContentTitle;
            placeholder.message = self.noContentMessage;
            placeholder.image = self.noContentImage;
            placeholder.buttonTitle = nil;
            placeholder.buttonAction = nil;
        } else if ([self.loadingState isEqualToString:AAPLLoadStateError]) {
            placeholder.title = self.errorTitle;
            placeholder.message = self.errorMessage;
            placeholder.image = self.errorImage;
            placeholder.buttonTitle = self.errorButtonTitle;
            placeholder.buttonAction = self.errorButtonAction;
        }
    } else if ([cell isKindOfClass:[ALActivityIndicatorCell class]]) {
        ALActivityIndicatorCell *activity = cell;
        [activity.activityIndicatorView startAnimating];
    }
}

-(id)tableView:(UITableView *)tableView sizingCellWithIdentifier:(NSString *)identifier{
    id cell = self.sizingCells[identifier];
    if (!cell) {
        cell = [self tableView:tableView dequeueReusableCellWithIdentifier:identifier];
        self.sizingCells[identifier] = cell;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewAbstractCell *cell;
    
    if (self.showingPlaceholder) {
        cell = [self tableView:tableView dequeueReusableCellWithIdentifier:[self placeholderReuseIdentifier]];
        [cell updateFonts];
        [self configurePlaceholderCell:cell];
    } else {
        cell = [self tableView:tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierForRowAtIndexPath:indexPath]];
        [cell updateFonts];
        [self configureCell:cell forRowAtIndexPath:indexPath];
    }

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSNumber *cachedHeight = [self.rowHeightCache cachedHeightForRowAtIndexPath:indexPath];
    if (cachedHeight) return [cachedHeight doubleValue];
    
    ALTableViewAbstractCell *cell;
    
    if (self.showingPlaceholder) {
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
    
    CGFloat height = [cell layoutSizeFittingWidth:CGRectGetWidth(tableView.bounds)].height;
    [self.rowHeightCache setCachedHeight:height forRowAtIndexPath:indexPath];
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *cachedHeight = [self.rowHeightCache cachedHeightForRowAtIndexPath:indexPath];
    if (cachedHeight) return [cachedHeight doubleValue];
    return tableView.estimatedRowHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (![self tableView:tableView sectionHasCustomHeader:section]) return UITableViewAutomaticDimension;
    
    UIView *view = [self tableView:tableView viewForHeaderInSection:section];
    [view setNeedsUpdateConstraints];
    [view updateConstraintsIfNeeded];
    
    return [view layoutSizeFittingWidth:CGRectGetWidth(tableView.bounds)].height;
}

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

#pragma mark - ContentLoading methods

- (AAPLLoadableContentStateMachine *)stateMachine
{
    if (_stateMachine)
        return _stateMachine;
    
    _stateMachine = [[AAPLLoadableContentStateMachine alloc] init];
    _stateMachine.delegate = self;
    return _stateMachine;
}

- (NSString *)loadingState
{
    // Don't cause the creation of the state machine just by inspection of the loading state.
    if (!_stateMachine)
        return AAPLLoadStateInitial;
    return _stateMachine.currentState;
}

- (void)setLoadingState:(NSString *)loadingState
{
    AAPLLoadableContentStateMachine *stateMachine = self.stateMachine;
    if (loadingState != stateMachine.currentState)
        stateMachine.currentState = loadingState;
}

- (void)beginLoading
{
    self.loadingComplete = NO;
    self.loadingState = (([self.loadingState isEqualToString:AAPLLoadStateInitial] || [self.loadingState isEqualToString:AAPLLoadStateLoadingContent] || [self.loadingState isEqualToString:AAPLLoadStateError]) ? AAPLLoadStateLoadingContent : AAPLLoadStateRefreshingContent);
    
    [self notifyWillLoadContent];
}

- (void)endLoadingWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
    self.loadingError = error;
    self.loadingState = state;
    
    [self notifyBatchUpdate:^{
        if (update)
            update();
    }];
    
    self.loadingComplete = YES;
    [self notifyContentLoadedWithError:error];
}

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
    block(loading);
}

- (void)whenLoaded:(dispatch_block_t)block
{
    __block int32_t complete = 0;
    
    [self aapl_addObserverForKeyPath:@"loadingComplete" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew withBlock:^(id obj, NSDictionary *change, id observer) {
        
        BOOL loadingComplete = [change[NSKeyValueChangeNewKey] boolValue];
        if (!loadingComplete)
            return;
        
        [self aapl_removeObserver:observer];
        
        // Already called the completion handler
        if (!OSAtomicCompareAndSwap32(0, 1, &complete))
            return;
        
        block();
    }];
}

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


-(void)setShowingPlaceholder:(BOOL)showingPlaceholder{
    if (_showingPlaceholder == showingPlaceholder) {
        if (showingPlaceholder) {
            [self invalidateCachedHeightsForIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
            [self notifyItemsRefreshedAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
        }
    } else {
        [self invalidateCachedHeights];
        [self notifyBatchUpdate:^{
            NSInteger oldNumberOfSections = self.numberOfSections;
            NSInteger oldNumberOfItemsInFirstSection = [self numberOfItemsInSection:0];
            
            _showingPlaceholder = showingPlaceholder;
            
            NSInteger newNumberOfSections = self.numberOfSections;
            NSInteger newNumberOfItemsInFirstSection = [self numberOfItemsInSection:0];
            
            if (newNumberOfSections > 0 && oldNumberOfSections > 0) {
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

- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertSections:direction:)]) {
        [delegate dataSource:self didInsertSections:sections direction:direction];
    }
}

- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveSections:direction:)]) {
        [delegate dataSource:self didRemoveSections:sections direction:direction];
    }
    
}

- (void)notifySectionsRefreshed:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshSections:direction:)]) {
        [delegate dataSource:self didRefreshSections:sections direction:direction];
    }
    
}

- (void)notifyDidReloadData{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidReloadData:)]) {
        [delegate dataSourceDidReloadData:self];
    }
}

- (void)notifyBatchUpdate:(dispatch_block_t)update
{
    [self notifyBatchUpdate:update complete:nil];
}

- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:performBatchUpdate:complete:)]) {
        [delegate dataSource:self performBatchUpdate:update complete:complete];
    }
    else {
        if (update) {
            update();
        }
        if (complete) {
            complete();
        }
    }
}

- (void)notifyContentLoadedWithError:(NSError *)error{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didLoadContentWithError:)]) {
        [delegate dataSource:self didLoadContentWithError:error];
    }
}

- (void)notifyWillLoadContent{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceWillLoadContent:)]) {
        [delegate dataSourceWillLoadContent:self];
    }
}

@end
