//
//  EZCollectionViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EZCollectionViewSection;
@class EZCollectionViewItem;
@class EZCollectionViewCell;

@interface EZCollectionViewController : UICollectionViewController
-(void)addSection:(EZCollectionViewSection *)section;
-(void)insertSection:(EZCollectionViewSection *)section atIndex:(NSInteger)index;
-(void)removeAllSections;

- (EZCollectionViewSection *)sectionAtIndex:(NSInteger)section;
- (EZCollectionViewItem *)itemForIndexPath:(NSIndexPath *)indexPath;

-(void)setupCell:(EZCollectionViewCell *)cell inCollectionView:(UICollectionView *)collectionView forItemAtIndexPath:(NSIndexPath *)indexPath;
@end
