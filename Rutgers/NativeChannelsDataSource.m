//
//  NativeChannelsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NativeChannelsDataSource.h"

@implementation NativeChannelsDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = [RUChannelManager sharedInstance].nativeChannels;
    }
    return self;
}
@end
