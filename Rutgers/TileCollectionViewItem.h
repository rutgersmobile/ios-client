//
//  TileCollectionViewItem.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewAbstractItem.h"

@interface TileCollectionViewItem : EZCollectionViewAbstractItem
-(instancetype)initWithText:(NSString *)text;
@property (nonatomic) NSString *text;

@property (nonatomic) BOOL showsEllipses;

@property (nonatomic) UIFont *textFont;

@end
