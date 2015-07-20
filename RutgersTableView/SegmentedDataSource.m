//
//  SegmentedDataSource.m
//  
//
//  Created by Kyle Bailey on 7/4/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "SegmentedDataSource.h"
#import "DataSource_Private.h"

@interface SegmentedDataSource () <DataSourceDelegate>
@property (nonatomic) NSMutableArray *dataSources;
@property (nonatomic) DataSource *selectedDataSource;
@property (nonatomic, strong) NSString *aggregateLoadingState;
@end

@implementation SegmentedDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataSources = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Segmented Data Source Interface
-(void)addDataSource:(DataSource *)dataSource{
    if (![self.dataSources count]) _selectedDataSource = dataSource;
    [self.dataSources addObject:dataSource];
    dataSource.delegate = self;
}

-(void)removeDataSource:(DataSource *)dataSource{
    [self.dataSources removeObject:dataSource];
    dataSource.delegate = nil;
}

#pragma mark - Setting Selected Segment
- (DataSource *)dataSourceAtIndex:(NSInteger)dataSourceIndex
{
    return self.dataSources[dataSourceIndex];
}

- (NSInteger)selectedDataSourceIndex
{
    return [self.dataSources indexOfObject:self.selectedDataSource];
}

- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex
{
    [self setSelectedDataSourceIndex:selectedDataSourceIndex animated:NO];
}

- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex animated:(BOOL)animated
{
    [self setSelectedDataSource:[self dataSourceAtIndex:selectedDataSourceIndex] animated:animated completion:nil];
}

- (void)setSelectedDataSource:(DataSource *)selectedDataSource
{
    [self setSelectedDataSource:selectedDataSource animated:NO completion:nil];
}

- (void)setSelectedDataSource:(DataSource *)selectedDataSource animated:(BOOL)animated
{
    [self setSelectedDataSource:selectedDataSource animated:animated completion:nil];
}

- (void)setSelectedDataSource:(DataSource *)selectedDataSource animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (_selectedDataSource == selectedDataSource) {
        if (completion)
            completion();
        return;
    }

    DataSource *oldDataSource = self.selectedDataSource;
    
    NSInteger oldIndex = [_dataSources indexOfObjectIdenticalTo:oldDataSource];
    NSInteger newIndex = [_dataSources indexOfObjectIdenticalTo:selectedDataSource];
    
    [self willChangeValueForKey:@"selectedDataSource"];
    [self willChangeValueForKey:@"selectedDataSourceIndex"];
    
    _selectedDataSource = selectedDataSource;
    
    if (animated) {
        [self notifyDidReloadDataWithDirection:(oldIndex < newIndex) ? DataSourceAnimationDirectionLeft : DataSourceAnimationDirectionRight];
    } else {
        [self notifyDidReloadDataWithDirection:DataSourceAnimationDirectionNone];
    }
    
    [self didChangeValueForKey:@"selectedDataSource"];
    [self didChangeValueForKey:@"selectedDataSourceIndex"];
    
    if ([selectedDataSource.loadingState isEqualToString:AAPLLoadStateInitial])
        [selectedDataSource setNeedsLoadContent];
    
    if (completion)
        completion();
    
}

#pragma mark Segmented Control action method

- (void)configureSegmentedControl:(UISegmentedControl *)segmentedControl
{
    NSArray *titles = [self.dataSources valueForKey:@"title"];
    
    [segmentedControl removeAllSegments];
    [titles enumerateObjectsUsingBlock:^(NSString *segmentTitle, NSUInteger segmentIndex, BOOL *stop) {
        if ([segmentTitle isEqual:[NSNull null]])
            segmentTitle = @"NULL";
        [segmentedControl insertSegmentWithTitle:segmentTitle atIndex:segmentIndex animated:NO];
    }];
    
    [segmentedControl removeTarget:nil action:nil forControlEvents:UIControlEventValueChanged];
    [segmentedControl addTarget:self action:@selector(selectedSegmentIndexChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = self.selectedDataSourceIndex;
}

- (void)selectedSegmentIndexChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (![segmentedControl isKindOfClass:[UISegmentedControl class]])
        return;
    
    segmentedControl.userInteractionEnabled = NO;
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    DataSource *dataSource = [self dataSourceAtIndex:selectedSegmentIndex];
    [self setSelectedDataSource:dataSource animated:NO completion:^{
        segmentedControl.userInteractionEnabled = YES;
    }];
}

#pragma mark - Segmented Data Source Implementation

-(NSInteger)numberOfSections{
    return self.selectedDataSource.numberOfSections;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return [self.selectedDataSource numberOfItemsInSection:section];
}

/// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
- (NSArray *)indexPathsForItem:(id)object
{
    return [self.selectedDataSource indexPathsForItem:object];;
}

/// Find the item at the specified index path.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.selectedDataSource itemAtIndexPath:indexPath];;
}

- (void)registerReusableViewsWithTableView:(UITableView *)tableView
{
    [super registerReusableViewsWithTableView:tableView];
    
    for (DataSource *dataSource in self.dataSources)
        [dataSource registerReusableViewsWithTableView:tableView];
}

#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.selectedDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.selectedDataSource tableView:tableView titleForHeaderInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.selectedDataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.selectedDataSource tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

#pragma mark - Collection View Data Source
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.selectedDataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - Cached Heights

-(void)invalidateCachedHeights{
    [super invalidateCachedHeights];
    for (DataSource *dataSource in self.dataSources) {
        [dataSource invalidateCachedHeights];
    }
}

#pragma mark - AAPLContentLoading

- (void)updateLoadingState
{
    // let's find out what our state should be by asking our data sources
    NSInteger numberOfLoading = 0;
    NSInteger numberOfRefreshing = 0;
    NSInteger numberOfError = 0;
    NSInteger numberOfLoaded = 0;
    NSInteger numberOfNoContent = 0;
    
    NSArray *loadingStates = [self.dataSources valueForKey:@"loadingState"];
    loadingStates = [loadingStates arrayByAddingObject:[super loadingState]];
    
    for (NSString *state in loadingStates) {
        if ([state isEqualToString:AAPLLoadStateLoadingContent])
            numberOfLoading++;
        else if ([state isEqualToString:AAPLLoadStateError])
            numberOfError++;
        else if ([state isEqualToString:AAPLLoadStateRefreshingContent])
            numberOfRefreshing++;
        else if ([state isEqualToString:AAPLLoadStateContentLoaded])
            numberOfLoaded++;
        else if ([state isEqualToString:AAPLLoadStateNoContent])
            numberOfNoContent++;
    }
    
    // Always prefer loading
    if (numberOfLoading > 1)
        _aggregateLoadingState = AAPLLoadStateLoadingContent;
    else if (numberOfError > 1)
        _aggregateLoadingState = AAPLLoadStateError;
    
    else if (numberOfRefreshing)
        _aggregateLoadingState = AAPLLoadStateRefreshingContent;
    else if (numberOfLoaded)
        _aggregateLoadingState = AAPLLoadStateContentLoaded;
    
    else if (numberOfLoading)
        _aggregateLoadingState = AAPLLoadStateLoadingContent;
    else if (numberOfError)
        _aggregateLoadingState = AAPLLoadStateError;
    else if (numberOfNoContent)
        _aggregateLoadingState = AAPLLoadStateNoContent;
    
    else
        _aggregateLoadingState = AAPLLoadStateInitial;
    
    [self updatePlaceholderState];

}

- (NSString *)loadingState
{
    if (!_aggregateLoadingState)
        [self updateLoadingState];
    return _aggregateLoadingState;
}

- (void)setLoadingState:(NSString *)loadingState
{
    _aggregateLoadingState = nil;
    [super setLoadingState:loadingState];
}

- (void)loadContent
{
    for (DataSource *dataSource in self.dataSources)
        [dataSource loadContent];
}

- (void)resetContent
{
    _aggregateLoadingState = nil;
    [super resetContent];
    for (DataSource *dataSource in self.dataSources)
        [dataSource resetContent];
}

- (void)stateDidChange
{
    [self updateLoadingState];
    [super stateDidChange];
}

#pragma mark - Placeholders

-(BOOL)shouldDisplayPlaceholder{
    return NO;
}

#pragma mark - Data Source Delegate

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsRemovedAtIndexPaths:removedIndexPaths direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsRefreshedAtIndexPaths:refreshedIndexPaths direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemMovedFromIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsRefreshed:sections direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsInserted:sections direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsRemoved:sections direction:direction];
    }
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource direction:(DataSourceAnimationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifyDidReloadDataWithDirection:direction];
    }
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    if (self.selectedDataSource == dataSource) {
        [self notifyBatchUpdate:update complete:complete];
    } else {
        if (update)
            update();
        if (complete)
            complete();
    }
}

-(void)dataSourceWillLoadContent:(DataSource *)dataSource{
    [self updateLoadingState];
    if (self.selectedDataSource == dataSource) {
        [self notifyWillLoadContent];
    }
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    [self updateLoadingState];
    if (self.selectedDataSource == dataSource) {
        [self notifyContentLoadedWithError:error];
    }
}

@end
