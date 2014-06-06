//
//  TileCollectionViewItem.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TileCollectionViewItem.h"
#import "EZCollectionViewCell.h"
#import "NSString+SHA1.h"

#define RANDOM_SEED 399

@implementation TileCollectionViewItem
static NSInteger seed = RANDOM_SEED;

+(NSInteger)seedNumber{
    return seed;
}

+(void)setSeedNumber:(NSInteger)seedNumber{
    seed = seedNumber;
}

-(void)setupCell:(EZCollectionViewCell *)cell{
    [super setupCell:cell];
    
    NSInteger seed = [[self class] seedNumber];
    
    CGFloat hue = ([self.text sha1] % seed)/(double)seed;
    
    cell.backgroundColor = [UIColor colorWithHue:hue saturation:0.9 brightness:0.60 alpha:1];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithHue:hue saturation:0.9 brightness:0.35 alpha:1];
    
    cell.showsEllipses = self.showsEllipses;
    cell.selectedBackgroundView = backgroundView;
}

@end
