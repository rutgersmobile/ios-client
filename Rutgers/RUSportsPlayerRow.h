//
//  RUSportsPlayerRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewAbstractRow.h"

@class RUSportsPlayer;

@interface RUSportsPlayerRow : EZTableViewAbstractRow
-(instancetype)initWithPlayer:(RUSportsPlayer *)player;
@end
