//
//  ComposedDataSource.m
//  
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "ComposedDataSource_Private.h"
#import "DataSource_Private.h"

@interface ComposedDataSource ()
@property (nonatomic, strong) NSString *aggregateLoadingState;
@end
@implementation ComposedDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataSources = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Composed Data Source Interface
-(DataSource *)dataSourceAtIndex:(NSInteger)index{
    return self.dataSources[index];
}

-(void)addDataSource:(DataSource *)dataSource{
    [self.dataSources addObject:dataSource];
    dataSource.delegate = self;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)];
    [dataSource notifySectionsInserted:sections];
}

-(void)insertDataSource:(DataSource *)dataSource atIndex:(NSInteger)index{
    [self.dataSources insertObject:dataSource atIndex:index];
    dataSource.delegate = self;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)];
    [dataSource notifySectionsInserted:sections];
}

-(void)removeDataSource:(DataSource *)dataSource{
    NSIndexSet *sections = [self globalSectionsForLocalSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)] inDataSource:dataSource];
    
    [self.dataSources removeObject:dataSource];
    dataSource.delegate = nil;
    
    [self notifySectionsRemoved:sections];
}

-(void)removeAllDataSources{
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    for (DataSource *dataSource in self.dataSources) {
        dataSource.delegate = nil;
    }
    [self.dataSources removeAllObjects];
    [self notifySectionsRemoved:sections];
}

#pragma mark - Composed Data Source Implementation
-(NSInteger)numberOfSections{
    NSInteger numberOfSections = 0;
    for (DataSource *dataSource in self.dataSources) {
        numberOfSections += dataSource.numberOfSections;
    }
    return numberOfSections;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    DataSource *dataSource = [self dataSourceForGlobalSection:section];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:section];
    return [dataSource numberOfItemsInSection:localSection];
}

/// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
- (NSArray *)indexPathsForItem:(id)object
{
    NSMutableArray *globalIndexPaths = [NSMutableArray array];
    for (DataSource *dataSource in self.dataSources) {
        NSArray *localIndexPaths = [dataSource indexPathsForItem:object];
        [globalIndexPaths addObjectsFromArray:[self globalIndexPathsForLocalIndexPaths:localIndexPaths inDataSource:dataSource]];
    }
    return globalIndexPaths;
}

/// Find the item at the specified index path.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:indexPath.section];
    return [dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:localSection]];
}

- (void)registerReusableViewsWithTableView:(UITableView *)tableView
{
    [super registerReusableViewsWithTableView:tableView];
    
    for (DataSource *dataSource in self.dataSources)
        [dataSource registerReusableViewsWithTableView:tableView];
}

#pragma mark - Cached Heights

-(void)invalidateCachedHeights{
    for (DataSource *dataSource in self.dataSources) {
        [dataSource invalidateCachedHeights];
    }
}

-(void)invalidateCachedHeightsForSection:(NSInteger)section{
    DataSource *dataSource = [self dataSourceForGlobalSection:section];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:section];
    [dataSource invalidateCachedHeightsForSection:localSection];
}

-(void)invalidateCachedHeightsForIndexPaths:(NSArray *)indexPaths{
    for (NSIndexPath *indexPath in indexPaths) {
        [self invalidateCachedHeightForIndexPath:indexPath];
    }
}

-(void)invalidateCachedHeightForIndexPath:(NSIndexPath *)indexPath{
    DataSource *dataSource = [self dataSourceForGlobalSection:indexPath.section];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    [dataSource invalidateCachedHeightsForIndexPaths:@[localIndexPath]];
}

#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource tableView:tableView cellForRowAtIndexPath:localIndexPath];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self dataSourceForGlobalSection:section].title;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [self dataSourceForGlobalSection:section].footer;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource tableView:tableView heightForRowAtIndexPath:localIndexPath];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource tableView:tableView estimatedHeightForRowAtIndexPath:localIndexPath];
}

#pragma mark - Collection View Data Source
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource collectionView:collectionView cellForItemAtIndexPath:localIndexPath];
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
        else if ([state isEqualToString:AAPLLoadStateRefreshingContent])
            numberOfRefreshing++;
        else if ([state isEqualToString:AAPLLoadStateError])
            numberOfError++;
        else if ([state isEqualToString:AAPLLoadStateContentLoaded])
            numberOfLoaded++;
        else if ([state isEqualToString:AAPLLoadStateNoContent])
            numberOfNoContent++;
    }
    
    //    NSLog(@"Composed.loadingState: loading = %d  refreshing = %d  error = %d  no content = %d  loaded = %d", numberOfLoading, numberOfRefreshing, numberOfError, numberOfNoContent, numberOfLoaded);
    
    // Always prefer loading
    if (numberOfLoading)
        _aggregateLoadingState = AAPLLoadStateLoadingContent;
    else if (numberOfRefreshing)
        _aggregateLoadingState = AAPLLoadStateRefreshingContent;
    else if (numberOfError)
        _aggregateLoadingState = AAPLLoadStateError;
    else if (numberOfNoContent)
        _aggregateLoadingState = AAPLLoadStateNoContent;
    else if (numberOfLoaded)
        _aggregateLoadingState = AAPLLoadStateContentLoaded;
    else
        _aggregateLoadingState = AAPLLoadStateInitial;
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
    [super stateDidChange];
    [self updateLoadingState];
}


#pragma mark - Data Source Delegate

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceOperationDirection)direction{
    [self notifyItemsInsertedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:insertedIndexPaths inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceOperationDirection)direction{
    [self notifyItemsRemovedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:removedIndexPaths inDataSource:dataSource] direction:direction];

}
-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceOperationDirection)direction{
    [self notifyItemsRefreshedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:refreshedIndexPaths inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    [self notifyItemMovedFromIndexPath:[self globalIndexPathForLocalIndexPath:indexPath inDataSource:dataSource]
                           toIndexPath:[self globalIndexPathForLocalIndexPath:newIndexPath inDataSource:dataSource]];
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [self notifySectionsRefreshed:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [self notifySectionsInserted:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [self notifySectionsRemoved:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection{
    // implement
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource{
    [self notifyDidReloadData];
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    [self notifyBatchUpdate:update complete:complete];
}

/// If the content was loaded successfully, the error will be nil.
- (void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error
{
    BOOL showingPlaceholder = self.shouldDisplayPlaceholder;
    [self updateLoadingState];
    
    // We were showing the placehoder and now we're not
    if (showingPlaceholder && !self.shouldDisplayPlaceholder)
        [self notifyBatchUpdate:^{
            [self executePendingUpdates];
        }];
    
    [self notifyContentLoadedWithError:error];
    [self updatePlaceholderNotifyVisibility:YES];
}

/// Called just before a datasource begins loading its content.
- (void)dataSourceWillLoadContent:(DataSource *)dataSource
{
    [self updateLoadingState];
    [self notifyWillLoadContent];
}


#pragma mark - Index Transformation
-(DataSource *)dataSourceForGlobalSection:(NSInteger)section{
    NSInteger remainderSection = section;
    for (DataSource *dataSource in self.dataSources) {
        NSInteger numberOfSections = dataSource.numberOfSections;
        if (remainderSection < numberOfSections) return dataSource;
        else remainderSection -= numberOfSections;
    }
    return nil;
}

#pragma mark Index Path
-(NSIndexPath *)localIndexPathInDataSource:(DataSource *)dataSource forGlobalIndexPath:(NSIndexPath *)globalIndexPath{
    return [NSIndexPath indexPathForRow:globalIndexPath.row inSection:[self localSectionInDataSource:dataSource forGlobalSection:globalIndexPath.section]];
}

-(NSIndexPath *)globalIndexPathForLocalIndexPath:(NSIndexPath *)localIndexPath inDataSource:(DataSource *)dataSource{
    return [NSIndexPath indexPathForRow:localIndexPath.row inSection:[self globalSectionForLocalSection:localIndexPath.section inDataSource:dataSource]];
}

#pragma mark Array of Index Paths
-(NSArray *)localIndexPathsInDataSource:(DataSource *)dataSource forGlobalIndexPaths:(NSArray *)globalIndexPaths{
    NSMutableArray *localIndexPaths = [NSMutableArray array];
    for (NSIndexPath *globalIndexPath in globalIndexPaths) {
        [localIndexPaths addObject:[self localIndexPathInDataSource:dataSource forGlobalIndexPath:globalIndexPath]];
    }
    return localIndexPaths;
}

-(NSArray *)globalIndexPathsForLocalIndexPaths:(NSArray *)localIndexPaths inDataSource:(DataSource *)dataSource{
    NSMutableArray *globalIndexPaths = [NSMutableArray array];
    for (NSIndexPath *localIndexPath in localIndexPaths) {
        [globalIndexPaths addObject:[self globalIndexPathForLocalIndexPath:localIndexPath inDataSource:dataSource]];
    }
    return globalIndexPaths;
}

#pragma mark Indexes
-(NSInteger)localSectionInDataSource:(DataSource *)dataSource forGlobalSection:(NSInteger)globalSection{
    NSInteger localSection = globalSection;
    for (DataSource *aDataSource in self.dataSources) {
        if (aDataSource == dataSource) return localSection;
        else localSection -= aDataSource.numberOfSections;
    }
    return 0;
}

-(NSInteger)globalSectionForLocalSection:(NSInteger)localSection inDataSource:(DataSource *)dataSource{
    NSInteger globalSection = localSection;
    for (DataSource *aDataSource in self.dataSources) {
        if (aDataSource == dataSource) return globalSection;
        else globalSection += aDataSource.numberOfSections;
    }
    return 0;
}

#pragma mark Index Sets
-(NSIndexSet *)localSectionsInDataSource:(DataSource *)dataSource forGlobalSections:(NSIndexSet *)globalSections{
    NSMutableIndexSet *localSections = [NSMutableIndexSet indexSet];
    NSUInteger globalSection = [globalSections firstIndex];
   
    while (globalSection != NSNotFound) {
        [localSections addIndex:[self localSectionInDataSource:dataSource forGlobalSection:globalSection]];
        globalSection = [globalSections indexGreaterThanIndex:globalSection];
    }
    
    return localSections;
}

-(NSIndexSet *)globalSectionsForLocalSections:(NSIndexSet *)localSections inDataSource:(DataSource *)dataSource{
    NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
    NSUInteger localSection = [localSections firstIndex];
 
    while (localSection != NSNotFound) {
        [globalSections addIndex:[self globalSectionForLocalSection:localSection inDataSource:dataSource]];
        localSection = [localSections indexGreaterThanIndex:localSection];
    }
    
    return globalSections;
}

@end
