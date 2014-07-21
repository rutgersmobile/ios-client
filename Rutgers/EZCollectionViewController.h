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

@interface EZCollectionViewController : UICollectionViewController <NetworkContentLoadingStateMachineDelegate>
-(UICollectionViewFlowLayout *)flowLayout;

-(void)addSection:(EZCollectionViewSection *)section;
-(void)insertSection:(EZCollectionViewSection *)section atIndex:(NSInteger)index;
-(void)removeAllSections;

@property (nonatomic) NSMutableArray *sections;

- (EZCollectionViewSection *)sectionAtIndex:(NSInteger)section;
- (EZCollectionViewAbstractItem *)itemForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) NetworkContentLoadingStateMachine * contentLoadingStateMachine;
-(void)setupContentLoadingStateMachine;
@end
