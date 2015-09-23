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
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithSportID:(NSString *)sportID NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSString *sportID;
-(void)toggleExpansionForPlayer:(RUSportsPlayer *)player;
@end
