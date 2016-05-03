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
        _dataSources = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Composed Data Source Interface
-(DataSource *)dataSourceAtIndex:(NSInteger)index{
    return self.dataSources[index];
}

/*
    Used for the Favourites Addition : 
    To Do : 
        Determine other uses... 
 
 */
-(void)addDataSource:(DataSource *)dataSource{
    [self.dataSources addObject:dataSource];
    dataSource.delegate = self;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)];
    [dataSource notifySectionsInserted:sections];
  //  [self updateLoadingState];
}

-(void)insertDataSource:(DataSource *)dataSource atIndex:(NSInteger)index{
    [self.dataSources insertObject:dataSource atIndex:index];
    dataSource.delegate = self;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)];
    [dataSource notifySectionsInserted:sections];
  ///  [self updateLoadingState];
}

-(void)removeDataSource:(DataSource *)dataSource{
    NSIndexSet *sections = [self globalSectionsForLocalSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)] inDataSource:dataSource];
    
    [self.dataSources removeObject:dataSource];
    dataSource.delegate = nil;
    
    [self notifySectionsRemoved:sections];
  //  [self updateLoadingState];
}

-(void)removeAllDataSources{
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    for (DataSource *dataSource in self.dataSources) {
        dataSource.delegate = nil;
    }
    [self.dataSources removeAllObjects];
    [self notifySectionsRemoved:sections];
}

-(void)setDataSources:(NSMutableArray *)dataSources{
    NSInteger oldNumberOfSections = [self numberOfSections];
    _dataSources = dataSources;
    for (DataSource *dataSource in dataSources) {
        dataSource.delegate = self;
    }
    NSInteger newNumberOfSections = [self numberOfSections];
    if (oldNumberOfSections > newNumberOfSections) {
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)]];
        [self notifySectionsRemoved:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newNumberOfSections, oldNumberOfSections - newNumberOfSections)]];
    } if (newNumberOfSections > oldNumberOfSections) {
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldNumberOfSections)]];
        [self notifySectionsInserted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(oldNumberOfSections, newNumberOfSections - oldNumberOfSections)]];
    } else {
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)]];
    }
}

#pragma mark - Composed Data Source Implementation
-(NSInteger)numberOfSections{
    if (self.showingPlaceholder) return 1;
    NSInteger numberOfSections = 0;
    for (DataSource *dataSource in self.dataSources) {
        numberOfSections += dataSource.numberOfSections;
    }
    return numberOfSections;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    if (self.showingPlaceholder) return 1;
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
    [super invalidateCachedHeights];
    for (DataSource *dataSource in self.dataSources) {
        [dataSource invalidateCachedHeights];
    }
}

#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showingPlaceholder) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource tableView:tableView cellForRowAtIndexPath:localIndexPath];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.showingPlaceholder) return nil;
    DataSource *dataSource = [self dataSourceForGlobalSection:section];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:section];
    return [dataSource tableView:tableView titleForHeaderInSection:localSection];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (self.showingPlaceholder) return nil;
    DataSource *dataSource = [self dataSourceForGlobalSection:section];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:section];
    return [dataSource tableView:tableView titleForFooterInSection:localSection];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showingPlaceholder) return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource tableView:tableView heightForRowAtIndexPath:localIndexPath];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showingPlaceholder) return [super tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource tableView:tableView estimatedHeightForRowAtIndexPath:localIndexPath];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    if ([dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
        return [dataSource tableView:tableView canEditRowAtIndexPath:localIndexPath];
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    if ([dataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
        [dataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:localIndexPath];
    }
}

#pragma mark - Collection View Data Source
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showingPlaceholder) return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
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
    BOOL should = [super shouldDisplayPlaceholder];
    return (should && (self.singleLoadingIndicator || (self.dataSources.count == 0)));
}


#pragma mark - Data Source Delegate

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimationDirection)direction{
    if (!self.showingPlaceholder) [self notifyItemsInsertedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:insertedIndexPaths inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimationDirection)direction{
    if (!self.showingPlaceholder) [self notifyItemsRemovedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:removedIndexPaths inDataSource:dataSource] direction:direction];

}
-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimationDirection)direction{
    if (!self.showingPlaceholder) [self notifyItemsRefreshedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:refreshedIndexPaths inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    if (!self.showingPlaceholder) [self notifyItemMovedFromIndexPath:[self globalIndexPathForLocalIndexPath:indexPath inDataSource:dataSource]
                           toIndexPath:[self globalIndexPathForLocalIndexPath:newIndexPath inDataSource:dataSource]];
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    if (!self.showingPlaceholder) [self notifySectionsRefreshed:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    if (!self.showingPlaceholder) [self notifySectionsInserted:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction{
    if (!self.showingPlaceholder) [self notifySectionsRemoved:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection{
    if (!self.showingPlaceholder) [self notifySectionMovedFrom:[self globalSectionForLocalSection:section inDataSource:dataSource] to:[self globalSectionForLocalSection:newSection inDataSource:dataSource]];
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource direction:(DataSourceAnimationDirection)direction{
    [self notifyDidReloadDataWithDirection:direction];
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    [self notifyBatchUpdate:update complete:complete];
}

/// If the content was loaded successfully, the error will be nil.
- (void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error
{
    [self updateLoadingState];
    [self notifyContentLoadedWithError:error];
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
