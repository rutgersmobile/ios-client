//
//  EZCollectionViewItem.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewAbstractItem.h"
#import "ColoredTileCollectionViewCell.h"

@implementation EZCollectionViewAbstractItem

-(instancetype)initWithIdentifier:(NSString *)identifier{
    self = [super init];
    if (self) {
        self.shouldHighlight = YES;
        _identifier = identifier;
    }
    return self;
}
- (instancetype)init
{
    self = [self initWithIdentifier:@"Cell"];
    if (self) {
        
    }
    return self;
}
-(void)setupCell:(UICollectionViewCell *)cell{
    
}

@end
