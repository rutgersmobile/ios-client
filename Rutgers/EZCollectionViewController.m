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
@property (nonatomic) NSMutableArray *sections;

@end

@implementation EZCollectionViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sections = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout = flowLayout;
    // Set up the collection view with no scrollbars, paging enabled
    // and the delegate and data source set to this view controller
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.opaque = YES;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addSection:(EZCollectionViewSection *)section{
    [self.sections addObject:section];
}

-(void)insertSection:(EZCollectionViewSection *)section atIndex:(NSInteger)index{
    [self.sections insertObject:section atIndex:index];
}

-(void)removeAllSections{
    NSInteger count = self.sections.count;
    [self.sections removeAllObjects];
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
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
