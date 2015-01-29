//
//  DataSource_Private.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "DataSource.h"
#import "AAPLPlaceholderView.h"

@interface DataSource ()
- (void)updatePlaceholderState;

- (void)stateWillChange;
- (void)stateDidChange;

-(void)invalidateCachedHeightsForSection:(NSInteger)section;
-(void)invalidateCachedHeightsForIndexPaths:(NSArray *)indexPaths;

/*
- (void)enqueuePendingUpdateBlock:(dispatch_block_t)block;
- (void)executePendingUpdates;
*/

/// Is this data source the root data source? This depends on proper set up of the delegate property. Container data sources ALWAYS act as the delegate for their contained data sources.
@property (nonatomic, readonly, getter = isRootDataSource) BOOL rootDataSource;

/// Whether this data source should display the placeholder.
@property (nonatomic, readonly) BOOL shouldDisplayPlaceholder;
@property (nonatomic) BOOL showingPlaceholder;

#pragma mark - Subclass hooks

- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;
- (id)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier;
- (void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)configurePlaceholderCell:(id)cell;

- (NSString *)reuseIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(id)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Notifications

// Use these methods to notify the observers of changes to the dataSource.
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths;
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths;
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths;
- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimationDirection)direction;
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimationDirection)direction;
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimationDirection)direction;

- (void)notifySectionsInserted:(NSIndexSet *)sections;
- (void)notifySectionsRemoved:(NSIndexSet *)sections;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections;
- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection;

- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction;
- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction;

- (void)notifyDidReloadData;

- (void)notifyBatchUpdate:(dispatch_block_t)update;
- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)notifyWillLoadContent;
- (void)notifyContentLoadedWithError:(NSError *)error;

@end

