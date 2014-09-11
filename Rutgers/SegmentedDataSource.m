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

    if (!animated) {
        [self willChangeValueForKey:@"selectedDataSource"];
        [self willChangeValueForKey:@"selectedDataSourceIndex"];
        
        _selectedDataSource = selectedDataSource;
        
        [self didChangeValueForKey:@"selectedDataSource"];
        [self didChangeValueForKey:@"selectedDataSourceIndex"];
        
        [self notifyDidReloadData];
        
        if ([selectedDataSource.loadingState isEqualToString:AAPLLoadStateInitial])
            [selectedDataSource setNeedsLoadContent];
        
        if (completion)
            completion();
        return;
    }
    
    DataSource *oldDataSource = self.selectedDataSource;
    NSInteger numberOfOldSections = oldDataSource.numberOfSections;
    NSInteger numberOfNewSections = selectedDataSource.numberOfSections;
    
    NSInteger oldIndex = [_dataSources indexOfObjectIdenticalTo:oldDataSource];
    NSInteger newIndex = [_dataSources indexOfObjectIdenticalTo:selectedDataSource];
    
    DataSourceOperationDirection removalDirection = (oldIndex < newIndex) ? DataSourceOperationDirectionLeft : DataSourceOperationDirectionRight;
    DataSourceOperationDirection insertionDirection = (oldIndex < newIndex) ? DataSourceOperationDirectionRight : DataSourceOperationDirectionLeft;
    
    NSIndexSet *removedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfOldSections)];;
    NSIndexSet *insertedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfNewSections)];
    
    [self notifyBatchUpdate:^{
        [self willChangeValueForKey:@"selectedDataSource"];
        [self willChangeValueForKey:@"selectedDataSourceIndex"];
        
        _selectedDataSource = selectedDataSource;

        if (removedSet)
            [self notifySectionsRemoved:removedSet direction:removalDirection];
        if (insertedSet)
            [self notifySectionsInserted:insertedSet direction:insertionDirection];
        
        [self didChangeValueForKey:@"selectedDataSource"];
        [self didChangeValueForKey:@"selectedDataSourceIndex"];
        
        if ([selectedDataSource.loadingState isEqualToString:AAPLLoadStateInitial])
            [selectedDataSource setNeedsLoadContent];
        
    } complete:completion];
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
    for (DataSource *dataSource in self.dataSources) {
        [dataSource invalidateCachedHeights];
    }
}
-(void)invalidateCachedHeightsForSection:(NSInteger)section{
    [self.selectedDataSource invalidateCachedHeightsForSection:section];
}

-(void)invalidateCachedHeightsForIndexPaths:(NSArray *)indexPaths{
    [self.selectedDataSource invalidateCachedHeightsForIndexPaths:indexPaths];
}


#pragma mark - AAPLContentLoading

- (void)loadContent
{
    //[_selectedDataSource loadContent];
    
    for (DataSource *dataSource in self.dataSources)
        [dataSource loadContent];
}

- (void)resetContent
{
    for (DataSource *dataSource in self.dataSources)
        [dataSource resetContent];
    [super resetContent];
}

-(NSString *)loadingState{
    return _selectedDataSource.loadingState;
}


#pragma mark - Placeholders

- (BOOL)shouldDisplayPlaceholder
{
    if ([super shouldDisplayPlaceholder])
        return YES;
    
    NSString *loadingState = _selectedDataSource.loadingState;
    
    // If we're in the error state & have an error message or title
    if ([loadingState isEqualToString:AAPLLoadStateError] && (_selectedDataSource.errorMessage || _selectedDataSource.errorTitle))
        return YES;
    
    // Only display a placeholder when we're loading or have no content
    if (![loadingState isEqualToString:AAPLLoadStateLoadingContent] && ![loadingState isEqualToString:AAPLLoadStateNoContent])
        return NO;
    
    // Can't display the placeholder if both the title and message is missing
    if (!_selectedDataSource.noContentMessage && !_selectedDataSource.noContentTitle)
        return NO;
    
    return YES;
}

- (void)updatePlaceholder:(AAPLPlaceholderCell *)placeholderView notifyVisibility:(BOOL)notify
{
    [_selectedDataSource updatePlaceholder:placeholderView notifyVisibility:notify];
}

- (NSString *)noContentMessage
{
    return _selectedDataSource.noContentMessage;
}

- (NSString *)noContentTitle
{
    return _selectedDataSource.noContentTitle;
}

- (UIImage *)noContentImage
{
    return _selectedDataSource.noContentImage;
}

- (NSString *)errorTitle
{
    return _selectedDataSource.errorTitle;
}

- (NSString *)errorMessage
{
    return _selectedDataSource.errorMessage;
}

- (UIImage *)errorImage
{
    return _selectedDataSource.errorImage;
}


#pragma mark - Data Source Delegate

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsRemovedAtIndexPaths:removedIndexPaths direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsRefreshedAtIndexPaths:refreshedIndexPaths direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemMovedFromIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsRefreshed:sections direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsInserted:sections direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsRemoved:sections direction:direction];
    }
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource{
    if (self.selectedDataSource == dataSource) {
        [self notifyDidReloadData];
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
    if (self.selectedDataSource == dataSource) {
        [self notifyWillLoadContent];
    }
}
-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    if (self.selectedDataSource == dataSource) {
        [self notifyContentLoadedWithError:error];
    }
}
@end
