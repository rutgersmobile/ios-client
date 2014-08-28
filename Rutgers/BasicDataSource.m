//
//  ArrayDataSource.m
//
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "BasicDataSource.h"
#import "DataSource_Private.h"
#import "NSArray+LimitedToCount.h"

@interface BasicDataSource ()
@end

@implementation BasicDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = @[];
    }
    return self;
}

-(instancetype)initWithItems:(NSArray *)items{
    self = [super init];
    if (self) {
        self.items = items;
    }
    return self;
}

- (void)resetContent
{
    [super resetContent];
    self.items = @[];
}

-(NSInteger)numberOfItems{
    return self.items.count;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return self.numberOfItems;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger itemIndex = indexPath.item;
    if (itemIndex < [_items count])
        return _items[itemIndex];
    
    return nil;
}

- (NSArray *)indexPathsForItem:(id)item
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger objectIndex, BOOL *stop) {
        if ([obj isEqual:item]) [indexPaths addObject:[NSIndexPath indexPathForItem:objectIndex inSection:0]];
    }];
    return indexPaths;
}

- (void)setItems:(NSArray *)items
{
    if (self.itemLimit) {
        [self setItems:[items limitedToCount:self.itemLimit] animated:YES];
    } else {
        [self setItems:items animated:YES];
    }
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    if (_items == items || [_items isEqualToArray:items])
        return;
    
    if (!self.delegate) {
        _items = [items copy];
        [self updateLoadingStateFromItems];
        return;
    }
    
    if (!animated) {
        _items = [items copy];
        [self invalidateCachedHeightsForSection:0];
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
        [self updateLoadingStateFromItems];
        return;
    }
    
    NSOrderedSet *oldItemSet = [NSOrderedSet orderedSetWithArray:_items];
    NSOrderedSet *newItemSet = [NSOrderedSet orderedSetWithArray:items];
    
    NSMutableOrderedSet *deletedItems = [oldItemSet mutableCopy];
    [deletedItems minusOrderedSet:newItemSet];
    
    NSMutableOrderedSet *newItems = [newItemSet mutableCopy];
    [newItems minusOrderedSet:oldItemSet];
    
    NSMutableOrderedSet *movedItems = [newItemSet mutableCopy];
    [movedItems intersectOrderedSet:oldItemSet];
    
    NSMutableArray *deletedIndexPaths = [NSMutableArray arrayWithCapacity:[deletedItems count]];
    for (id deletedItem in deletedItems) {
        [deletedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:deletedItem] inSection:0]];
    }
    
    NSMutableArray *insertedIndexPaths = [NSMutableArray arrayWithCapacity:[newItems count]];
    for (id newItem in newItems) {
        [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:newItem] inSection:0]];
    }
    
    NSMutableArray *fromMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
    NSMutableArray *toMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
    for (id movedItem in movedItems) {
        [fromMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:movedItem] inSection:0]];
        [toMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:movedItem] inSection:0]];
    }
    
    [self notifyBatchUpdate:^{
        
        [self invalidateCachedHeightsForSection:0];
        
        _items = [items copy];
        
        if ([deletedIndexPaths count])
            [self notifyItemsRemovedAtIndexPaths:deletedIndexPaths];
        
        if ([insertedIndexPaths count])
            [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths];
        
        NSUInteger count = [fromMovedIndexPaths count];
        for (NSUInteger i = 0; i < count; ++i) {
            NSIndexPath *fromIndexPath = fromMovedIndexPaths[i];
            NSIndexPath *toIndexPath = toMovedIndexPaths[i];
            [self notifyItemMovedFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
        }
        
    }];
    
    [self updateLoadingStateFromItems];
}

- (void)updateLoadingStateFromItems
{
    NSString *loadingState = self.loadingState;
    NSUInteger numberOfItems = [_items count];
    if (numberOfItems && [loadingState isEqualToString:AAPLLoadStateNoContent])
        self.loadingState = AAPLLoadStateContentLoaded;
    else if (!numberOfItems && [loadingState isEqualToString:AAPLLoadStateContentLoaded])
        self.loadingState = AAPLLoadStateNoContent;
}

@end
