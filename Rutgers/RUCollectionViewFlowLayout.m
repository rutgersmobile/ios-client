//
//  RUCollectionViewFlowLayout.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUCollectionViewFlowLayout.h"
#import "iPadCheck.h"

@interface RUCollectionViewFlowLayout ()
@property CGFloat tileAspectRatio;
@property CGFloat maxTileWidth;
@property CGFloat tileSpacing;
@property CGFloat tilePadding;
@property CGRect lastBounds;
@property BOOL isResizing;
@end

@implementation RUCollectionViewFlowLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tileSpacing = 2;
        self.tilePadding = 3;
        
        self.tileAspectRatio = 203.0/170.0;
        self.maxTileWidth = iPad() ? 180.0 : 130;
        
        self.sectionInset = UIEdgeInsetsMake(self.tilePadding, self.tilePadding, self.tilePadding, self.tilePadding);
        
        self.minimumInteritemSpacing = self.tileSpacing;
        self.minimumLineSpacing = self.tileSpacing;
        
    }
    return self;
}

-(void)prepareLayout{
    [self calculateItemSize];
    [super prepareLayout];
}

-(void)calculateItemSize{
    CGFloat layoutWidth = CGRectGetWidth(self.collectionView.bounds) - self.tilePadding * 2;
    NSInteger number = ceil((layoutWidth + self.tileSpacing) / (self.maxTileWidth + self.tileSpacing));
    
    CGFloat tileWidth = (layoutWidth - (number-1) * self.tileSpacing) / number;
    
    self.itemSize = CGSizeMake(floorf(tileWidth), floorf(tileWidth/self.tileAspectRatio));
}

-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes *initialAttributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if (self.isResizing) return initialAttributes;
    
    CGPoint center = initialAttributes.center;
    center.x -= CGRectGetWidth(self.collectionView.bounds);
    center.y -= 50;
    
    initialAttributes.center = center;
    initialAttributes.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    return initialAttributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    BOOL should = [super shouldInvalidateLayoutForBoundsChange:newBounds];
    return should;
}

-(void)prepareForAnimatedBoundsChange:(CGRect)oldBounds{
    self.isResizing = YES;
    [self invalidateLayout];
    [super prepareForAnimatedBoundsChange:oldBounds];
}

-(void)finalizeAnimatedBoundsChange{
    [super finalizeAnimatedBoundsChange];
    self.isResizing = NO;
}

@end
