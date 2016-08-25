//
//  DataSource.h
//  
//
//  Created by Kyle Bailey on 6/24/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//


/*
    Data Source :
        Seems to be used to arrange the icons on the side bar ... 
 
    Data SOurce conforms the the AAPLContentLoading protocol and this manages the state machine , and how the data is loaded into the Data Source ..
 
 */
#import <UIKit/UIKit.h>
#import "AAPLContentLoading.h"
#import <AFNetworkReachabilityManager.h>

@class DataSource;
@class ALPlaceholderCell;

typedef NS_ENUM(int, DataSourceAnimationDirection) {
    DataSourceAnimationDirectionNone = 0,
    DataSourceAnimationDirectionLeft = -1,
    DataSourceAnimationDirectionRight = 1,
    
};

@protocol DataSourceDelegate <NSObject>
@optional
- (void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths direction:(DataSourceAnimationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths direction:(DataSourceAnimationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths direction:(DataSourceAnimationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceAnimationDirection)direction;
- (void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)dataSourceDidReloadData:(DataSource *)dataSource direction:(DataSourceAnimationDirection)direction;
- (void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

- (void)dataSourceWillLoadContent:(DataSource *)dataSource;
- (void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error;

@end


@interface DataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource, AAPLContentLoading>

/// A delegate object that will receive change notifications from this data source.
@property (nonatomic, weak) id<DataSourceDelegate> delegate;

/// The title of this data source. This value is used to populate section headers and the segmented control tab.
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *footer;

/// The number of sections in this data source.
@property (nonatomic, readonly) NSInteger numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/// Find the item at the specified index path.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

/// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
- (NSArray *)indexPathsForItem:(id)item;
- (NSArray *)indexPathsForTitle:(id)title;


-(void)invalidateCachedHeights;

#pragma mark - Subclass hooks
/// Register reusable views needed by this data source
- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView NS_REQUIRES_SUPER;
- (void)registerReusableViewsWithTableView:(UITableView *)tableView NS_REQUIRES_SUPER;

- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)reuseIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(id)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Placeholders

@property (nonatomic, copy) NSString *noContentTitle;
@property (nonatomic, copy) NSString *noContentMessage;
@property (nonatomic, strong) UIImage *noContentImage;

@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *errorTitle;
@property (nonatomic, strong) UIImage *errorImage;
@property (nonatomic, copy) NSString *errorButtonTitle;
@property (nonatomic, copy) dispatch_block_t errorButtonAction;

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)configurePlaceholderCell:(ALPlaceholderCell *)cell;

#pragma mark - Content loading

/// Signal that the datasource SHOULD reload its content
- (void)setNeedsLoadContent;

/// Load the content of this data source.
- (void)loadContent;

/// Reset the content and loading state.
- (void)resetContent NS_REQUIRES_SUPER;

/// Use this method to wait for content to load. The block will be called once the loadingState has transitioned to the ContentLoaded, NoContent, or Error states. If the data source is already in that state, the block will be called immediately.
- (void)whenLoaded:(dispatch_block_t)block;

@end
