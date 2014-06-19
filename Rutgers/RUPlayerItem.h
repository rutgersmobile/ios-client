//
//  RUPlayerCardItem.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewAbstractItem.h"
@class RUSportsPlayer;

@interface RUPlayerItem : EZCollectionViewAbstractItem
-(instancetype)initWithSportsPlayer:(RUSportsPlayer *)player;
@end
