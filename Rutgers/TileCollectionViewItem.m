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


#define FONT_SIZE  (iPad() ? 22 : 16.0)

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

    cell.showsEllipses = self.showsEllipses;
    
}@end
