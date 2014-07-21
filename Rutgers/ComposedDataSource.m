//
//  ComposedDataSource.m
//  
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "ComposedDataSource_Private.h"

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

#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:indexPath.section];
    NSIndexPath *localIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:localSection];
    return [dataSource tableView:tableView cellForRowAtIndexPath:localIndexPath];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self dataSourceForGlobalSection:section].title;
}

#pragma mark - Collection View Data Source
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:indexPath.section];
    NSIndexPath *localIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:localSection];
    return [dataSource collectionView:collectionView cellForItemAtIndexPath:localIndexPath];
}


#pragma mark - AAPLContentLoading

- (void)loadContent
{
    for (DataSource *dataSource in self.dataSources)
        [dataSource loadContent];
}

#pragma mark - Data Source Delegate

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths{
    [self notifyItemsInsertedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:insertedIndexPaths inDataSource:dataSource]];
}
-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths{
    [self notifyItemsRemovedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:removedIndexPaths inDataSource:dataSource]];

}
-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths{
    [self notifyItemsRefreshedAtIndexPaths:[self globalIndexPathsForLocalIndexPaths:refreshedIndexPaths inDataSource:dataSource]];
}
-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    [self notifyItemMovedFromIndexPath:[self globalIndexPathForLocalIndexPath:indexPath inDataSource:dataSource]
                           toIndexPath:[self globalIndexPathForLocalIndexPath:newIndexPath inDataSource:dataSource]];
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    [self notifySectionsRefreshed:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    [self notifySectionsInserted:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}
-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction{
    [self notifySectionsRemoved:[self globalSectionsForLocalSections:sections inDataSource:dataSource] direction:direction];
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource{
    [self notifyDidReloadData];
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    [self notifyBatchUpdate:update complete:complete];

}

-(void)dataSourceWillLoadContent:(DataSource *)dataSource{
    [self notifyWillLoadContent];
}
-(void)dataSource:(DataSource *)dataSource contentLoadedWithError:(NSError *)error{
    [self notifyContentLoadedWithError:error];
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
