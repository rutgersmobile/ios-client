//  ComposedDataSource.m
//  
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "ComposedDataSource_Private.h"
#import "DataSource_Private.h"

/*
    Class Function : 
        Holds multiple Data Sources :
    But is that being used to display anything ? 
        What is the use of composed data source ? 
    May be is it used to display items in a table view ?
 
 */

@interface ComposedDataSource ()
@property (nonatomic, strong) NSString *aggregateLoadingState;
@end
@implementation ComposedDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
       _dataSources = [NSMutableArray array]; // an array to hold the multiple data sources
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
 
    Seems to be used for all the different types of information obtained
    Data source is a generic object providing the information to be dispalyed by the view controller and composedDataSources contain multiple data source 
    How are they used ? 
        Does each bus route have a specific data source or does each stop ? How is it used?
 */
-(void)addDataSource:(DataSource *)dataSource
{
    [self.dataSources addObject:dataSource];
    dataSource.delegate = self;
    // creates a unique set out the multiple data sources. Why is this done ,for better addressing ? <q>
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)];
    [dataSource notifySectionsInserted:sections];
  //  [self updateLoadingState];
}

/*
    <q>
        Adds the data source to an array within this class, sets its delegate to be the current class and we notify that 
        sections have been added to the data source ?
        Why are sections being added to the data source
 */
-(void)insertDataSource:(DataSource *)dataSource atIndex:(NSInteger)index{
    [self.dataSources insertObject:dataSource atIndex:index];
    dataSource.delegate = self;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)];
    
    [dataSource notifySectionsInserted:sections]; // why notify the data source about the inserted items ?
  ///  [self updateLoadingState];
}

-(void)removeDataSource:(DataSource *)dataSource{
    NSIndexSet *sections = [self globalSectionsForLocalSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataSource.numberOfSections)] inDataSource:dataSource];
    
    [self.dataSources removeObject:dataSource];
    dataSource.delegate = nil;
    
    [self notifySectionsRemoved:sections];
    
    // for removal the current class is notified , but for addition , the data source is notified , is this an error <q> [:w
  //  [self updateLoadingState];
}

-(void)removeAllDataSources
{
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    for (DataSource *dataSource in self.dataSources)
    {
        dataSource.delegate = nil;
    }
    [self.dataSources removeAllObjects];
    [self notifySectionsRemoved:sections];
}

/*
    Add a set of new Data Sources ?
    The previous Data Sources is removed and the provided Data  Source is used as the data sources 
    
    if the previous number of section is more than the current number of sections , then we remove the previous sections
    else if we have more sections , then we add the new sections and refresh the old sections . Why is this done , why is the previous section not being removed ?
 */
-(void)setDataSources:(NSMutableArray *)dataSources
{
    NSInteger oldNumberOfSections = [self numberOfSections];
    _dataSources = dataSources;
    
    for (DataSource *dataSource in dataSources)
    {
        dataSource.delegate = self;
    }
    
    NSInteger newNumberOfSections = [self numberOfSections];
    
    if (oldNumberOfSections > newNumberOfSections)
    {
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)]];
        [self notifySectionsRemoved:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newNumberOfSections, oldNumberOfSections - newNumberOfSections)]];
    }
    if (newNumberOfSections > oldNumberOfSections)
    {
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldNumberOfSections)]];
        [self notifySectionsInserted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(oldNumberOfSections, newNumberOfSections - oldNumberOfSections)]];
    }
    else
    {
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)]];
    }
}

/*
    Each data source is not mapped to a single section , but rather , the sections of a single data source are added to the global sections.
    , such that the global sections are made up of multiple data sources and the multiple sections of each of the data sources
 
 */
#pragma mark - Composed Data Source Implementation
-(NSInteger)numberOfSections
{
    if (self.showingPlaceholder) return 1;
    NSInteger numberOfSections = 0;
    for (DataSource *dataSource in self.dataSources)
    {
        numberOfSections += dataSource.numberOfSections;
    }
    return numberOfSections;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    if (self.showingPlaceholder) return 1;
    DataSource *dataSource = [self dataSourceForGlobalSection:section];
    // obtain local section from global section?
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:section]; /// which is the local section depend on the global sectio
        // shouldn't the local section we restricted to within the data Source ? <q>
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


/*
    Register the 3 seperate views that holds the route view , bus view etc .
 */
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

/*
    Used to populate Table View Cells for 
        - BUS
 
 */


#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showingPlaceholder) return [super tableView:tableView cellForRowAtIndexPath:indexPath];  // ???? Place Holder seems to be the error message that is displayed?
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];   // Create data source from
    NSIndexPath *localIndexPath = [self localIndexPathInDataSource:dataSource forGlobalIndexPath:indexPath];
    return [dataSource tableView:tableView cellForRowAtIndexPath:localIndexPath];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.showingPlaceholder) return nil;
    DataSource *dataSource = [self dataSourceForGlobalSection:section];
    NSInteger localSection = [self localSectionInDataSource:dataSource forGlobalSection:section];
    return [dataSource tableView:tableView titleForHeaderInSection:localSection];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
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

/*
    Used for editing elements in the data source ..     
    Transform is done to locate a particule cell in the global data source catering to multiple sections
 
 */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger globalSection = indexPath.section;
    DataSource *dataSource = [self dataSourceForGlobalSection:globalSection];  // The data source of multiple sections might be same , so editing an item in a
                                                                            // particular section will require having to pin point the cell in the data source
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
   
        /*
            AP class seems to have a state machine and that might be used <q>
         
         */
    
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
    
    /*
        _aggregate... must refer to a state variable , which controls the state at which data is stored
     */
    
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


/*
    <q> What is aggregate loading state :
        Multiple cells get updated ??
 
 */
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

/*
 How the index being Transformed ? From Global to Local , but what does that mean ? ????

    Obtains the mapping between data sources and section , it is not a one to one mapping , as a single data source can have mulitple sections  
    which area added to the global sections
 
 */
#pragma mark - Index Transformation
-(DataSource *)dataSourceForGlobalSection:(NSInteger)section{
    NSInteger remainderSection = section;
    for (DataSource *dataSource in self.dataSources) {  // Go through each of the data sources , keep on reducing until the number of
        NSInteger numberOfSections = dataSource.numberOfSections;
        // what is the logic in this part of the code <q>
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
