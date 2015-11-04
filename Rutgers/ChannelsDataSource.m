//
//  NativeChannelsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ChannelsDataSource.h"
#import "RUChannelManager.h"

@implementation ChannelsDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = [RUChannelManager sharedInstance].contentChannels;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelsDidChange) name:ChannelManagerDidUpdateChannelsKey object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)channelsDidChange{
    self.items = [RUChannelManager sharedInstance].contentChannels;
}
@end
