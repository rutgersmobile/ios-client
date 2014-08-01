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
#import "RUCollectionViewFlowLayout.h"


@interface EZCollectionViewController ()
@property (nonatomic) NSMutableDictionary *layoutCells;
@property (nonatomic) UIRefreshControl *refreshControl;
@end

@implementation EZCollectionViewController
- (instancetype)init
{
    self = [super initWithCollectionViewLayout:[[RUCollectionViewFlowLayout alloc] init]];
    if (self) {
        self.sections = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

/*
-(void)setupContentLoadingStateMachine{
    NetworkContentStateIndicatorView *indicatorView = [[NetworkContentStateIndicatorView alloc] initForAutoLayout];
    [self.view addSubview:indicatorView];
    [indicatorView autoCenterInSuperview];
    
    self.contentLoadingStateMachine = [[NetworkContentLoadingStateMachine alloc] initWithStateIndicatorView:indicatorView];
    
   // self.refreshControl = [[UIRefreshControl alloc] init];
   // self.contentLoadingStateMachine.refreshControl =  self.refreshControl;
    self.contentLoadingStateMachine.delegate = self;
    [self.contentLoadingStateMachine startNetworking];
}*/

-(UICollectionViewFlowLayout *)flowLayout{
    return (UICollectionViewFlowLayout *)self.collectionViewLayout;
}

-(void)addSection:(EZCollectionViewSection *)section{
    if (self.isViewLoaded) {
        [self.collectionView performBatchUpdates:^{
            [self.sections addObject:section];
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.sections.count-1]];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.sections addObject:section];
    }
}

-(void)insertSection:(EZCollectionViewSection *)section atIndex:(NSInteger)index{
    if (self.isViewLoaded) {
        [self.collectionView performBatchUpdates:^{
            [self.sections insertObject:section atIndex:index];
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:index]];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.sections insertObject:section atIndex:index];
    }
}

-(void)removeAllSections{
    if (!self.sections.count) return;
    
    if (self.isViewLoaded) {
        [self.collectionView performBatchUpdates:^{
            NSInteger count = self.sections.count;
            [self.sections removeAllObjects];
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.sections removeAllObjects];
    }
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
