//
//  RUSportsRosterPlayerHeaderRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsRosterPlayerHeaderRow.h"
#import "RUSportsRosterPlayerHeaderCell.h"

@interface RUSportsRosterPlayerHeaderRow ()
@property (nonatomic) RUSportsPlayer *player;
@end

@implementation RUSportsRosterPlayerHeaderRow
-(instancetype)initWithPlayer:(RUSportsPlayer *)player{
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

-(void)setupCell:(RUSportsRosterPlayerHeaderCell *)cell{
    
}
@end
