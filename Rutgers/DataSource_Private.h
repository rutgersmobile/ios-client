//
//  DataSource_Private.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DataSource.h"
#import "AAPLPlaceholderView.h"

typedef enum {
    DataSourceOperationDirectionNone = 0,
    DataSourceOperationDirectionLeft,
    DataSourceOperationDirectionRight,
} DataSourceOperationDirection;

@protocol DataSourceDelegate <NSObject>
@optional
- (void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths;
- (void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths;
- (void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths;
- (void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection direction:(DataSourceOperationDirection)direction;

- (void)dataSourceDidReloadData:(DataSource *)dataSource;
- (void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)dataSourceWillLoadContent:(DataSource *)dataSource;
- (void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error;
@end

@interface DataSource ()

- (AAPLCollectionPlaceholderView *)dequeuePlaceholderViewForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

- (void)updatePlaceholder:(AAPLCollectionPlaceholderView *)placeholderView notifyVisibility:(BOOL)notify;

- (void)stateWillChange;
- (void)stateDidChange;

- (void)enqueuePendingUpdateBlock:(dispatch_block_t)block;
- (void)executePendingUpdates;


/// Is this data source the root data source? This depends on proper set up of the delegate property. Container data sources ALWAYS act as the delegate for their contained data sources.
@property (nonatomic, readonly, getter = isRootDataSource) BOOL rootDataSource;

/// Whether this data source should display the placeholder.
@property (nonatomic, readonly) BOOL shouldDisplayPlaceholder;

/// A delegate object that will receive change notifications from this data source.
@property (nonatomic, weak) id<DataSourceDelegate> delegate;


#pragma mark - Notifications

// Use these methods to notify the observers of changes to the dataSource.
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths;
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths;
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths;
- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)notifySectionsInserted:(NSIndexSet *)sections;
- (void)notifySectionsRemoved:(NSIndexSet *)sections;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections;
- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection;

- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction;
- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction;
- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection direction:(DataSourceOperationDirection)direction;

- (void)notifyDidReloadData;

- (void)notifyBatchUpdate:(dispatch_block_t)update;
- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)notifyWillLoadContent;
- (void)notifyContentLoadedWithError:(NSError *)error;

@end
