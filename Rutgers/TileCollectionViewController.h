//
//  TileCollectionViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewController.h"

@interface TileCollectionViewController : EZCollectionViewController
@property (nonatomic) CGFloat maxTileWidth;
@property (nonatomic) CGFloat tileAspectRatio;
@property (nonatomic) CGFloat tileSpacing;
@property (nonatomic) CGFloat tilePadding;
@end
