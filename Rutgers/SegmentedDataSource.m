//
//  SegmentedDataSource.m
//  
//
//  Created by Kyle Bailey on 7/4/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "SegmentedDataSource.h"

@interface SegmentedDataSource () <DataSourceDelegate>
/// A reference to the selected data source.
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
    
  //  [self notifyWillBeginUpdate];
    
 
    NSAssert([_dataSources containsObject:selectedDataSource], @"selected data source must be contained in this data source");
    
    
    DataSource *oldDataSource = self.selectedDataSource;
    NSInteger numberOfOldSections = oldDataSource.numberOfSections;
    NSInteger numberOfNewSections = selectedDataSource.numberOfSections;
    
    DataSourceSectionOperationDirection removalDirection = DataSourceSectionOperationDirectionNone;
    DataSourceSectionOperationDirection insertionDirection = DataSourceSectionOperationDirectionNone;
    if (animated) {
        NSInteger oldIndex = [_dataSources indexOfObjectIdenticalTo:oldDataSource];
        NSInteger newIndex = [_dataSources indexOfObjectIdenticalTo:selectedDataSource];
      
        removalDirection = (oldIndex < newIndex) ? DataSourceSectionOperationDirectionLeft : DataSourceSectionOperationDirectionRight;
        insertionDirection = (oldIndex < newIndex) ? DataSourceSectionOperationDirectionRight : DataSourceSectionOperationDirectionLeft;
    }
    
    NSIndexSet *removedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfOldSections)];;
    NSIndexSet *insertedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfNewSections)];
    
    [self willChangeValueForKey:@"selectedDataSource"];
    [self willChangeValueForKey:@"selectedDataSourceIndex"];
   
    [self notifyBatchUpdate:^{
        if (removedSet)
            [self notifySectionsRemoved:removedSet direction:removalDirection];
        
        _selectedDataSource = selectedDataSource;
        if (insertedSet)
            [self notifySectionsInserted:insertedSet direction:insertionDirection];
        
    } complete:completion];
    _selectedDataSource = nil;

    [self didChangeValueForKey:@"selectedDataSource"];
    [self didChangeValueForKey:@"selectedDataSourceIndex"];
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
    [segmentedControl addTarget:self action:@selector(selectedSegmentIndexChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = self.selectedDataSourceIndex;
    [segmentedControl sizeToFit];
}

- (void)selectedSegmentIndexChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (![segmentedControl isKindOfClass:[UISegmentedControl class]])
        return;
    
    segmentedControl.userInteractionEnabled = NO;
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    DataSource *dataSource = [self dataSourceAtIndex:selectedSegmentIndex];
    [self setSelectedDataSource:dataSource animated:YES completion:^{
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

#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.selectedDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;//[self.selectedDataSource tableView:tableView titleForHeaderInSection:section];
}

#pragma mark - Collection View Data Source
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.selectedDataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - AAPLContentLoading

- (void)loadContent
{
    // Only load the currently selected data source. Others will be loaded as necessary.
    [_selectedDataSource loadContent];
}

#pragma mark - Data Source Delegate

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths];
    }
}
-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsRemovedAtIndexPaths:removedIndexPaths];
    }
}
-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemsRefreshedAtIndexPaths:refreshedIndexPaths];
    }
}
-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    if (self.selectedDataSource == dataSource) {
        [self notifyItemMovedFromIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsRefreshed:sections direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    if (self.selectedDataSource == dataSource) {
        [self notifySectionsInserted:sections direction:direction];
    }
}
-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
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
-(void)dataSource:(DataSource *)dataSource contentLoadedWithError:(NSError *)error{
    if (self.selectedDataSource == dataSource) {
        [self notifyContentLoadedWithError:error];
    }
}
@end
