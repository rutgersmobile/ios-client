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
-(id)initWithSportID:(NSString *)sportID;

-(void)toggleExpansionForPlayer:(RUSportsPlayer *)player;
@end
