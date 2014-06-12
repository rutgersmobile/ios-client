//
//  TileCollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#define TILE_PADDING 4
#define TILE_SPACING 3

#import "TileCollectionViewController.h"
#import "TileCollectionViewCell.h"
#import "iPadCheck.h"

@interface TileCollectionViewController ()

@end

@implementation TileCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[TileCollectionViewCell class] forCellWithReuseIdentifier:@"DynamicCollectionViewCell"];
    self.tileSpacing = TILE_SPACING;
    self.tilePadding = TILE_PADDING;
    self.tileAspectRatio = 203.0/170.0;
    self.maxTileWidth = iPad() ? 180.0 : 120.0;
}

-(void)setTileSpacing:(CGFloat)tileSpacing{
    _tileSpacing = tileSpacing;
    self.flowLayout.minimumInteritemSpacing = tileSpacing;
    self.flowLayout.minimumLineSpacing = tileSpacing;
}
-(void)setTilePadding:(CGFloat)tilePadding{
    _tilePadding = tilePadding;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(tilePadding, tilePadding, tilePadding, tilePadding);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionViewFlowLayout Delegate

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    [self clearSelection];
}
-(void)clearSelection{
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.lastObject;
    [self.collectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    CGFloat layoutWidth = CGRectGetWidth(collectionView.bounds)-self.tilePadding*2;
    NSInteger number = 0;
    CGFloat width = 0;
    
    while (width < layoutWidth) {
        number++;
        width += self.maxTileWidth + self.tileSpacing;
    }
    
    CGFloat tileWidth = (layoutWidth - (number-1)*self.tileSpacing) / number;

    return CGSizeMake(floorf(tileWidth), floorf(tileWidth/self.tileAspectRatio));
}
@end
