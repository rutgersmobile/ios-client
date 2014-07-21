//
//  TileCollectionViewItem.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TileCollectionViewItem.h"
#import "TileCollectionViewCell.h"
#import "EZCollectionViewController.h"
#import "iPadCheck.h"
#import <HexColor.h>

#define FONT_SIZE  (iPad() ? 22 : 16.0)

@implementation TileCollectionViewItem

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

-(void)setupCell:(TileCollectionViewCell *)cell{
    [super setupCell:cell];
    cell.textLabel.text = self.text;
    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];

    cell.showsEllipses = self.showsEllipses;
    
}@end
