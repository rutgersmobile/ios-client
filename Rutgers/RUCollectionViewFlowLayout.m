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
        self.tileSpacing = 3;
        self.tilePadding = 4;
        
        self.tileAspectRatio = 203.0/170.0;
        self.maxTileWidth = iPad() ? 180.0 : 130;
        
        self.sectionInset = UIEdgeInsetsMake(self.tilePadding, self.tilePadding, self.tilePadding, self.tilePadding);
        
        self.minimumInteritemSpacing = self.tileSpacing;
        self.minimumLineSpacing = self.tileSpacing;
    }
    return self;
}

-(void)prepareLayout{
    self.itemSize = [self calculateItemSize];
    [super prepareLayout];
}


-(void)invalidateLayout{
    self.itemSize = [self calculateItemSize];
    [super invalidateLayout];
}

-(CGSize)calculateItemSize{
    CGFloat layoutWidth = CGRectGetWidth(self.collectionView.bounds)-self.tilePadding*2;
    NSInteger number = 0;
    CGFloat width = 0;
    
    while (width < layoutWidth) {
        number++;
        width += self.maxTileWidth + self.tileSpacing;
    }
    
    CGFloat tileWidth = (layoutWidth - (number-1)*self.tileSpacing) / number;
    
    return CGSizeMake(floorf(tileWidth), floorf(tileWidth/self.tileAspectRatio));
}


-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes *initialAttributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if (self.isResizing) return initialAttributes;
    
  //  CGFloat belowScreenHeight = CGRectGetHeight(self.collectionView.bounds) + 40;
  //  CGFloat screenCenterX = CGRectGetMidX(self.collectionView.bounds);
  
  //  CGFloat leftOfScreen = -80;
 //   CGFloat screenCenterY = CGRectGetMidY(self.collectionView.bounds);
    
    
    CGPoint center = initialAttributes.center;
    center.x -= CGRectGetWidth(self.collectionView.bounds);
    center.y -= 50;
    
    initialAttributes.center = center;
    initialAttributes.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    return initialAttributes;
}

-(void)prepareForAnimatedBoundsChange:(CGRect)oldBounds{
    self.isResizing = YES;
}

-(void)finalizeAnimatedBoundsChange{
    self.isResizing = NO;
}

@end
