//
//  RUFavoritesDataSource.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/20/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUFavoritesDataSource.h"
#import "RUChannelManager.h"
#import "RUUserInfoManager.h"
#import "RUMenuTableViewCell.h"
#import "RUFavorite.h"

@implementation RUFavoritesDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = [RUUserInfoManager favorites];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesDidChange) name:userInfoManagerDidChangeFavoritesKey object:nil];
    }
    return self;
}

-(void)configureCell:(RUMenuTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUFavorite *favorite = [self itemAtIndexPath:indexPath];
    NSDictionary *channel = [[RUChannelManager sharedInstance] channelWithHandle:favorite.channelHandle];
    [cell setupForChannel:channel];
    cell.channelTitleLabel.text = favorite.title;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)favoritesDidChange{
    self.items = [RUUserInfoManager favorites];
}
@end
