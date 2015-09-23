//
//  RUSportsRosterPlayerHeaderRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


@class RUSportsPlayer;

@interface RUSportsRosterPlayerHeaderRow : NSObject
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithPlayer:(RUSportsPlayer *)player NS_DESIGNATED_INITIALIZER;
@end
