//
//  TileDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TileDataSource.h"
#import "TileCollectionViewCell.h"
#import "iPadCheck.h"
#import "TileCollectionViewItem.h"

@implementation TileDataSource
-(void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView{
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[TileCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TileCollectionViewCell class])];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TileCollectionViewCell class]) forIndexPath:indexPath];
    TileCollectionViewItem *item = [self itemAtIndexPath:indexPath];
    
    cell.textLabel.text = item.title;
    cell.textLabel.font = [UIFont systemFontOfSize:(iPad() ? 22 : 16.0)];
    cell.showsEllipses = item.showsEllipses;
    
    cell.backgroundColor = [self colorForCollectionView:collectionView itemAtIndexPath:indexPath];
    
    cell.selectedBackgroundView = [self backgroundViewForCollectionView:collectionView itemAtIndexPath:indexPath];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

-(UIView *)backgroundViewForCollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)indexPath{
    UIColor *color = [self colorForCollectionView:collectionView itemAtIndexPath:indexPath];
    
    CGFloat hue, sat, bright, alpha;
    [color getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithHue:hue saturation:sat*1.2 brightness:bright/1.8 alpha:1];
    return backgroundView;
}

-(UIColor *)colorForCollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)indexPath{
    static NSArray *colorData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorData =  @[
                       @[@184, @100, @72],
                       @[@171, @97, @68],
                       @[@125, @64, @69],
                       @[@63, @77, @69],
                       @[@47, @100, @90],
                       @[@39, @100, @90],
                       @[@29, @96, @90],
                       @[@19, @93, @90],
                       @[@8, @90, @90]
                       ];
    });
    
    UIColor *(^colorWithIndex)(NSInteger) = ^UIColor* (NSInteger index){
        NSArray *entry = colorData[index];
        return [UIColor colorWithHue:[entry[0] doubleValue]/360.0 saturation:[entry[1] doubleValue]/100.0 brightness:[entry[2] doubleValue]/100.0 alpha:1];
    };
    
    NSInteger numberOfColors = colorData.count;
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:indexPath.section];
    NSInteger itemIndex = indexPath.row;
    
    if (numberOfColors == numberOfItems) {
        return colorWithIndex(itemIndex);
    } else if ((numberOfColors-1)*itemIndex % (numberOfItems-1) == 0) {
        return colorWithIndex((numberOfColors-1)*itemIndex/(numberOfItems-1));
    }
    
    CGFloat number = ((numberOfColors-1)*(itemIndex)/((CGFloat)numberOfItems-1));
    NSInteger lowBound = floor(number);
    NSInteger highBound = ceil(number);
    
    NSArray *entryOne = colorData[lowBound];
    NSArray *entryTwo = colorData[highBound];
    
    CGFloat ratio = number-lowBound;
    
    CGFloat hue = ([entryOne[0] doubleValue]*(1-ratio)+[entryTwo[0] doubleValue]*ratio)/360.0;
    CGFloat saturation = ([entryOne[1] doubleValue]*(1-ratio)+[entryTwo[1] doubleValue]*ratio)/100.0;
    CGFloat brightness = ([entryOne[2] doubleValue]*(1-ratio)+[entryTwo[2] doubleValue]*ratio)/100.0;
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
