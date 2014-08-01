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

@interface DataSource () <AAPLStateMachineDelegate>
@property (nonatomic, strong) AAPLLoadableContentStateMachine *stateMachine;
@property (nonatomic, strong) AAPLCollectionPlaceholderView *placeholderView;

@property (nonatomic, copy) dispatch_block_t pendingUpdateBlock;
@property (nonatomic) BOOL loadingComplete;
@property (nonatomic, weak) AAPLLoading *loadingInstance;
@property (nonatomic) NSMutableDictionary *sizingCells;
@end

@implementation DataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sizingCells = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Data Source Implementation
-(NSInteger)numberOfSections{
    return 1;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
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

-(BOOL)tableView:(UITableView *)tableView sectionHasCustomHeader:(NSInteger)section{
    return NO;
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(id)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier{
    return [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell = [self tableView:tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierForRowAtIndexPath:indexPath]];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}


-(id)tableView:(UITableView *)tableView sizingCellWithIdentifier:(NSString *)identifier{
    id cell = self.sizingCells[identifier];
    if (!cell) {
        cell = [self tableView:tableView dequeueReusableCellWithIdentifier:identifier];
        self.sizingCells[identifier] = cell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell = [self tableView:tableView sizingCellWithIdentifier:[self reuseIdentifierForRowAtIndexPath:indexPath]];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return [cell layoutSizeFittingSize:tableView.bounds.size].height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (![self tableView:tableView sectionHasCustomHeader:section]) return UITableViewAutomaticDimension;
    
    UIView *view = [self tableView:tableView viewForHeaderInSection:section];
    [view setNeedsUpdateConstraints];
    [view updateConstraintsIfNeeded];
    
    return [view layoutSizeFittingSize:tableView.bounds.size].height;
}

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self numberOfItemsInSection:section];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView{

}

#pragma mark - ContentLoading methods#pragma mark - AAPLContentLoading methods
@synthesize loadingError = _loadingError;

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
    self.loadingState = (([self.loadingState isEqualToString:AAPLLoadStateInitial] || [self.loadingState isEqualToString:AAPLLoadStateLoadingContent]) ? AAPLLoadStateLoadingContent : AAPLLoadStateRefreshingContent);
    
    [self notifyWillLoadContent];
}

- (void)endLoadingWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
    self.loadingError = error;
    self.loadingState = state;
    
    if (self.shouldDisplayPlaceholder) {
        if (update)
            [self enqueuePendingUpdateBlock:update];
    }
    else {
        [self notifyBatchUpdate:^{
            // Run pending updates
            [self executePendingUpdates];
            if (update)
                update();
        }];
    }
    
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
    
    __weak typeof(&*self) weakself = self;
    
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
    [self updatePlaceholder:self.placeholderView notifyVisibility:YES];
}

- (void)didEnterLoadedState
{
    [self updatePlaceholder:self.placeholderView notifyVisibility:YES];
}

- (void)didEnterNoContentState
{
    [self updatePlaceholder:self.placeholderView notifyVisibility:YES];
}

- (void)didEnterErrorState
{
    [self updatePlaceholder:self.placeholderView notifyVisibility:YES];
}

#pragma mark - Placeholder

- (BOOL)obscuredByPlaceholder
{
    if (self.shouldDisplayPlaceholder)
        return YES;
    
    if (!self.delegate)
        return NO;
    
    if (![self.delegate isKindOfClass:[DataSource class]])
        return NO;
    
    DataSource *dataSource = (DataSource *)self.delegate;
    return dataSource.obscuredByPlaceholder;
}

- (BOOL)shouldDisplayPlaceholder
{
    NSString *loadingState = self.loadingState;
    
    // If we're in the error state & have an error message or title
    if ([loadingState isEqualToString:AAPLLoadStateError] && (self.errorMessage || self.errorTitle))
        return YES;
    
    // Only display a placeholder when we're loading or have no content
    if (![loadingState isEqualToString:AAPLLoadStateLoadingContent] && ![loadingState isEqualToString:AAPLLoadStateNoContent])
        return NO;
    
    // Can't display the placeholder if both the title and message are missing
    if (!self.noContentMessage && !self.noContentTitle)
        return NO;
    
    return YES;
}

- (void)updatePlaceholder:(AAPLCollectionPlaceholderView *)placeholderView notifyVisibility:(BOOL)notify
{
    NSString *message;
    NSString *title;
    
    if (placeholderView) {
        NSString *loadingState = self.loadingState;
        if ([loadingState isEqualToString:AAPLLoadStateLoadingContent])
            [placeholderView showActivityIndicator:YES];
        else
            [placeholderView showActivityIndicator:NO];
        
        if ([loadingState isEqualToString:AAPLLoadStateNoContent]) {
            title = self.noContentTitle;
            message = self.noContentMessage;
            [placeholderView showPlaceholderWithTitle:title message:message image:self.noContentImage animated:YES];
        }
        else if ([loadingState isEqualToString:AAPLLoadStateError]) {
            title = self.errorTitle;
            message = self.errorMessage;
            [placeholderView showPlaceholderWithTitle:title message:message image:self.noContentImage animated:YES];
        }
        else
            [placeholderView hidePlaceholderAnimated:YES];
    }
    
    if (notify && (self.noContentTitle || self.noContentMessage || self.errorTitle || self.errorMessage))
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)]];
}

- (AAPLCollectionPlaceholderView *)dequeuePlaceholderViewForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    return nil;/*
    if (!_placeholderView)
        _placeholderView = [collectionView dequeueReusableSupplementaryViewOfKind:AAPLCollectionElementKindPlaceholder withReuseIdentifier:NSStringFromClass([AAPLCollectionPlaceholderView class]) forIndexPath:indexPath];
    [self updatePlaceholder:_placeholderView notifyVisibility:NO];
    return _placeholderView;*/
}


#pragma mark - Data Source Delegate
- (void)executePendingUpdates
{
    ASSERT_MAIN_THREAD;
    dispatch_block_t block = _pendingUpdateBlock;
    _pendingUpdateBlock = nil;
    if (block)
        block();
}

- (void)enqueuePendingUpdateBlock:(dispatch_block_t)block
{
    dispatch_block_t update;
    
    if (_pendingUpdateBlock) {
        dispatch_block_t oldPendingUpdate = _pendingUpdateBlock;
        update = ^{
            oldPendingUpdate();
            block();
        };
    }
    else {
        update = block;
    }
    
    self.pendingUpdateBlock = update;
}

// Use these methods to notify the observers of changes to the dataSource.
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertItemsAtIndexPaths:)]) {
        [delegate dataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths];
    }
    
}

- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveItemsAtIndexPaths:)]) {
        [delegate dataSource:self didRemoveItemsAtIndexPaths:removedIndexPaths];
    }
    
}

- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshItemsAtIndexPaths:)]) {
        [delegate dataSource:self didRefreshItemsAtIndexPaths:refreshedIndexPaths];
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
    [self notifySectionsInserted:sections direction:DataSourceOperationDirectionNone];
}

- (void)notifySectionsRemoved:(NSIndexSet *)sections{
    [self notifySectionsRemoved:sections direction:DataSourceOperationDirectionNone];
}

- (void)notifySectionsRefreshed:(NSIndexSet *)sections{
    [self notifySectionsRefreshed:sections direction:DataSourceOperationDirectionNone];
}

- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection
{
    [self notifySectionMovedFrom:section to:newSection direction:DataSourceOperationDirectionNone];
}

- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertSections:direction:)]) {
        [delegate dataSource:self didInsertSections:sections direction:direction];
    }
}

- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveSections:direction:)]) {
        [delegate dataSource:self didRemoveSections:sections direction:direction];
    }
    
}

- (void)notifySectionsRefreshed:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    ASSERT_MAIN_THREAD;

    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshSections:direction:)]) {
        [delegate dataSource:self didRefreshSections:sections direction:direction];
    }
    
}

- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection direction:(DataSourceOperationDirection)direction
{
    ASSERT_MAIN_THREAD;
    
    id<DataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveSection:toSection:direction:)]) {
        [delegate dataSource:self didMoveSection:section toSection:newSection direction:direction];
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
