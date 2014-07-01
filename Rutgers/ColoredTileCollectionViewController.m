//
//  ColoredTileCollectionViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ColoredTileCollectionViewController.h"

@interface ColoredTileCollectionViewController ()

@end

@implementation ColoredTileCollectionViewController

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    UIColor *color = [self colorForCollectionView:collectionView cell:cell atIndexPath:indexPath];
    
    cell.backgroundColor = color;
    
    CGFloat hue, sat, bright, alpha;
    [color getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithHue:hue saturation:sat*1.2 brightness:bright/1.8 alpha:1];
    cell.selectedBackgroundView = backgroundView;

    return cell;
}

-(UIColor *)colorForCollectionView:(UICollectionView *)collectionView cell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    static NSArray *colorData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorData =  @[
                       @[@184, @100, @82],
                       @[@171, @97, @78],
                       @[@125, @39, @79],
                       @[@63, @57, @79],
                       @[@47, @95, @100],
                       @[@39, @90, @100],
                       @[@29, @86, @100],
                       @[@19, @83, @100],
                       @[@8, @80, @100]
                       ];
    });
    
    UIColor *(^colorWithIndex)(NSInteger) = ^ UIColor* (NSInteger index){
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
    
    //   NSLog(@"%f, %f, %f",hue,saturation,brightness);
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
