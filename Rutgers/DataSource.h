//
//  DataSource.h
//  
//
//  Created by Kyle Bailey on 6/24/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAPLContentLoading.h"


@class DataSource;
@class LayoutMetrics;

typedef enum {
    DataSourceSectionOperationDirectionNone = 0,
    DataSourceSectionOperationDirectionLeft,
    DataSourceSectionOperationDirectionRight,
} DataSourceSectionOperationDirection;

@protocol DataSourceDelegate <NSObject>
@optional
- (void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths;
- (void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths;
- (void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths;
- (void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction;

- (void)dataSourceDidReloadData:(DataSource *)dataSource;
- (void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)dataSourceWillLoadContent:(DataSource *)dataSource;
- (void)dataSource:(DataSource *)dataSource contentLoadedWithError:(NSError *)error;
@end

@interface DataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource, AAPLContentLoading>

@property (nonatomic, weak) id<DataSourceDelegate> delegate;

/// The title of this data source. This value is used to populate section headers and the segmented control tab.
@property (nonatomic, copy) NSString *title;

-(NSString *)identifierForCellAtIndexPath:(NSIndexPath *)indexPath;
-(NSString *)identifierForHeaderInSection:(NSInteger)section;

/// The number of sections in this data source.
@property (nonatomic, readonly) NSInteger numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/// Find the item at the specified index path.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

/// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
- (NSArray *)indexPathsForItem:(id)item;

#pragma mark - Placeholders

@property (nonatomic, copy) NSString *noContentTitle;
@property (nonatomic, copy) NSString *noContentMessage;
@property (nonatomic, strong) UIImage *noContentImage;

@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *errorTitle;
@property (nonatomic, strong) UIImage *errorImage;

/// Is this data source "hidden" by a placeholder either of its own or from an enclosing data source. Use this to determine whether to report that there are no items in your data source while loading.
@property (nonatomic, readonly) BOOL obscuredByPlaceholder;

#pragma mark - Subclass hooks

/// Signal that the datasource SHOULD reload its content
- (void)setNeedsLoadContent;

/// Load the content of this data source.
- (void)loadContent;

/// Reset the content and loading state.
- (void)resetContent NS_REQUIRES_SUPER;

/// Use this method to wait for content to load. The block will be called once the loadingState has transitioned to the ContentLoaded, NoContent, or Error states. If the data source is already in that state, the block will be called immediately.
- (void)whenLoaded:(dispatch_block_t)block;

#pragma mark - Notifications

// Use these methods to notify the observers of changes to the dataSource.
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths;
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths;
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths;
- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)notifySectionsInserted:(NSIndexSet *)sections;
- (void)notifySectionsRemoved:(NSIndexSet *)sections;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections;

- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction;
- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections direction:(DataSourceSectionOperationDirection)direction;

- (void)notifyDidReloadData;

- (void)notifyBatchUpdate:(dispatch_block_t)update;
- (void)notifyBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)notifyWillLoadContent;
- (void)notifyContentLoadedWithError:(NSError *)error;

@end
