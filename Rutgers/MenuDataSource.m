//
//  MenuDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "MenuDataSource.h"
#import "DataSource_Private.h"
#import "ChannelsDataSource.h"
#import "RUUserInfoManager.h"
#import "RUChannelManager.h"
#import "RUFavoritesDataSource.h"

@implementation MenuDataSource
-(instancetype)init{
    self = [super init];
    if (self) {
        [self addDataSource:[[RUFavoritesDataSource alloc] init]];
        [self addDataSource:[[ChannelsDataSource alloc] init]];
        [self addDataSource:[[MenuBasicDataSource alloc] initWithItems:[RUChannelManager sharedInstance].otherChannels]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyDidReloadData) name:userInfoManagerDidChangeInfoKey object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
