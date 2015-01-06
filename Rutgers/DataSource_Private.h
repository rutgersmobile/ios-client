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
    DataSourceAnimationFade = 0,
    DataSourceAnimationLeft,
    DataSourceAnimationRight,
    
} DataSourceAnimation;

@protocol DataSourceDelegate <NSObject>
@optional
- (void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimation)direction;
- (void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimation)direction;
- (void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimation)direction;
- (void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceAnimation)direction;
- (void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceAnimation)direction;
- (void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceAnimation)direction;
- (void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)dataSourceDidReloadData:(DataSource *)dataSource;
- (void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)dataSourceWillLoadContent:(DataSource *)dataSource;
- (void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error;

@end

@interface DataSource ()
- (void)updatePlaceholder;

- (void)stateWillChange;
- (void)stateDidChange;

- (void)enqueuePendingUpdateBlock:(dispatch_block_t)block;
- (void)executePendingUpdates;

/// Is this data source the root data source? This depends on proper set up of the delegate property. Container data sources ALWAYS act as the delegate for their contained data sources.
@property (nonatomic, readonly, getter = isRootDataSource) BOOL rootDataSource;

/// Whether this data source should display the placeholder.
@property (nonatomic, readonly) BOOL shouldDisplayPlaceholder;
@property (nonatomic) BOOL showingPlaceholder;

/// Is this data source "hidden" by a placeholder either of its own or from an enclosing data source. Use this to determine whether to report that there are no items in your data source while loading.
//@property (nonatomic, readonly) BOOL obscuredByPlaceholder;

/// A delegate object that will receive change notifications from this data source.
@property (nonatomic, weak) id<DataSourceDelegate> delegate;

#pragma mark - Notifications

// Use these methods to notify the observers of changes to the dataSource.
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths;
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths;
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths;
- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimation)direction;
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimation)direction;
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimation)direction;

- (void)notifySectionsInserted:(NSIndexSet *)sections;
- (void)notifySectionsRemoved:(NSIndexSet *)sections;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections;
- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection;

- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceAnimation)direction;
- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceAnimation)direction;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections direction:(DataSourceAnimation)direction;

- (void)notifyDidReloadData;

- (void)notifyBatchUpdate:(dispatch_block_t)update;
- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)notifyWillLoadContent;
- (void)notifyContentLoadedWithError:(NSError *)error;

@end

