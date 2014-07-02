//
//  EZCollectionViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>


@class EZCollectionViewSection;
@class EZCollectionViewAbstractItem;

@interface EZCollectionViewController : UICollectionViewController
-(UICollectionViewFlowLayout *)flowLayout;

-(void)addSection:(EZCollectionViewSection *)section;
-(void)insertSection:(EZCollectionViewSection *)section atIndex:(NSInteger)index;
-(void)removeAllSections;

-(void)startNetworkLoad;
-(void)networkLoadSucceeded;
-(void)networkLoadFailed;

@property (nonatomic) NSMutableArray *sections;

- (EZCollectionViewSection *)sectionAtIndex:(NSInteger)section;
- (EZCollectionViewAbstractItem *)itemForIndexPath:(NSIndexPath *)indexPath;

@end
