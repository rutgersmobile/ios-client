//
//  RosterDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"
@class RUSportsPlayer;

@interface RosterDataSource : BasicDataSource
@property (nonatomic) NSString *sportID;
-(instancetype)initWithSportID:(NSString *)sportID NS_DESIGNATED_INITIALIZER;

-(void)toggleExpansionForPlayer:(RUSportsPlayer *)player;
@end
