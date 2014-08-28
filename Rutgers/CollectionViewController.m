//
//  CollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "CollectionViewController.h"
#import "DataSource_Private.h"

@interface CollectionViewController () <DataSourceDelegate>
@property (nonatomic) DataSource *dataSource;
@end

@implementation CollectionViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    

    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

-(void)preferredContentSizeChanged{
    [self.collectionView reloadData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

@synthesize dataSource = _dataSource;

-(DataSource *)dataSource{
    return _dataSource;
}

-(void)setDataSource:(DataSource *)dataSource{
    _dataSource.delegate = nil;
    _dataSource = dataSource;
    
    dataSource.delegate = self;
    self.collectionView.dataSource = dataSource;
    [dataSource registerReusableViewsWithCollectionView:self.collectionView];
    
    [self.collectionView reloadData];
    [dataSource setNeedsLoadContent];
}

-(UITableViewRowAnimation)rowAnimationForSectionOperationDirection:(DataSourceOperationDirection)direction{
    switch (direction) {
        case DataSourceOperationDirectionNone:
            return UITableViewRowAnimationAutomatic;
            break;
        case DataSourceOperationDirectionLeft:
            return UITableViewRowAnimationLeft;
            break;
        case DataSourceOperationDirectionRight:
            return UITableViewRowAnimationRight;
            break;
    }
}

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths{
    [self.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
}

-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths{
    [self.collectionView deleteItemsAtIndexPaths:removedIndexPaths];
}

-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths{
    [self.collectionView reloadItemsAtIndexPaths:refreshedIndexPaths];
}

-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [self.collectionView reloadSections:sections];
}

-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [self.collectionView insertSections:sections];
}

-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    [self.collectionView deleteSections:sections];
}

-(void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection{
    [self.collectionView moveSection:section toSection:newSection];
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource{
    [self.collectionView reloadData];
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    
    [self.collectionView performBatchUpdates:update completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
    }];

}

-(void)dataSourceWillLoadContent:(DataSource *)dataSource{
    
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    
}

@end
