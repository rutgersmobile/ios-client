//
//  EZCollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewController.h"
#import "EZCollectionViewSection.h"
#import "EZCollectionViewAbstractItem.h"
#import "TileCollectionViewCell.h"

@interface EZCollectionViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic) NSMutableDictionary *layoutCells;
@end

@implementation EZCollectionViewController
- (instancetype)init
{
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        self.sections = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}


-(void)startNetworkLoad{
 
}

-(void)networkLoadSucceeded{
}

-(void)networkLoadFailed{
}

-(UICollectionViewFlowLayout *)flowLayout{
    return (UICollectionViewFlowLayout *)self.collectionViewLayout;
}

-(void)addSection:(EZCollectionViewSection *)section{
    [self.collectionView performBatchUpdates:^{
        [self.sections addObject:section];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.sections.count-1]];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)insertSection:(EZCollectionViewSection *)section atIndex:(NSInteger)index{
    [self.collectionView performBatchUpdates:^{
        [self.sections insertObject:section atIndex:index];
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:index]];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)removeAllSections{
    [self.collectionView performBatchUpdates:^{
        NSInteger count = self.sections.count;
        [self.sections removeAllObjects];
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
    } completion:^(BOOL finished) {
        
    }];
}

- (EZCollectionViewSection *)sectionAtIndex:(NSInteger)section{
    return self.sections[section];
}

- (EZCollectionViewAbstractItem *)itemForIndexPath:(NSIndexPath *)indexPath{
    return [[self sectionAtIndex:indexPath.section] itemAtIndex:indexPath.row];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[self sectionAtIndex:section] numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self itemForIndexPath:indexPath].identifier forIndexPath:indexPath];
    [[self itemForIndexPath:indexPath] setupCell:cell];
    return cell;
}

#pragma mark - CollectionView Delegate

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemForIndexPath:indexPath].shouldHighlight;

}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    EZCollectionViewAbstractItem *item = [self itemForIndexPath:indexPath];
    if (item.didSelectItemBlock) {
        item.didSelectItemBlock();
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.sections.count;
}

@end
