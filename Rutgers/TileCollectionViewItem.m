//
//  TileCollectionViewItem.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TileCollectionViewItem.h"
#import "TileCollectionViewCell.h"
#import "NSString+SHA1.h"
#import "EZCollectionViewController.h"
#import "iPadCheck.h"
#import <HexColor.h>

#define RANDOM_SEED 398


#define FONT_SIZE  (iPad() ? 20 : 16.0)

@implementation TileCollectionViewItem
static NSInteger seed = RANDOM_SEED;

-(id)init{
    self = [super initWithIdentifier:@"DynamicCollectionViewCell"];
    if (self) {
        self.textFont = [UIFont systemFontOfSize:17];
    }
    return self;
}

-(instancetype)initWithText:(NSString *)text{
    self = [self init];
    if (self) {
        self.text = text;
    }
    return self;
}

+(NSInteger)seedNumber{
    return seed;
}

+(void)setSeedNumber:(NSInteger)seedNumber{
    seed = seedNumber;
}

-(void)setupCell:(TileCollectionViewCell *)cell{
    [super setupCell:cell];
    cell.textLabel.text = self.text;
    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    
    NSInteger seed = [[self class] seedNumber];
    
    CGFloat hue = ([self.text sha1] % seed)/(double)seed;
    
    CGFloat start = 30;
    CGFloat finish = 220;
    CGFloat gap = finish-start;
    
    CGFloat gapRatio = gap/360.0;
    hue = hue*(1-gapRatio);
    if (hue > start/360.0) {
        hue += gapRatio;
    }
    
    CGFloat sat = 0.90;
    
    CGFloat bright = 0.60;
    
    cell.backgroundColor = [UIColor colorWithHue:hue saturation:sat brightness:bright alpha:1];
    
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithHue:hue saturation:sat*1.2 brightness:bright/1.8 alpha:1];
  
    cell.showsEllipses = self.showsEllipses;
    cell.selectedBackgroundView = backgroundView;
}


@end
