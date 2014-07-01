//
//  RUSportsRosterPlayerHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewAbstractRow.h"

@class RUSportsPlayer;

@interface RUSportsRosterPlayerHeaderRow : EZTableViewAbstractRow
-(instancetype)initWithPlayer:(RUSportsPlayer *)player;
@end
