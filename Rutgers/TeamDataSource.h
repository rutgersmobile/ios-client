//
//  TeamDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"
@class RUSportsPlayer;

@interface TeamDataSource : ComposedDataSource
-(id)initWithSportID:(NSString *)sportID;
@property (nonatomic) NSString *sportID;
-(void)toggleExpansionForPlayer:(RUSportsPlayer *)player;
@end
