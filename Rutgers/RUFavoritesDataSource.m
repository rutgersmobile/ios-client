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
    NSDictionary *favorite = [self itemAtIndexPath:indexPath];
    NSString *channelHandle = [[NSURL URLWithString:favorite[@"url"]] host];
    
    NSDictionary *channel = [[RUChannelManager sharedInstance] channelWithHandle:channelHandle];
    [cell setupForChannel:channel];
    cell.channelTitleLabel.text = favorite[@"title"];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)favoritesDidChange{
    self.items = [RUUserInfoManager favorites];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *favorite = [self itemAtIndexPath:indexPath];
    [RUUserInfoManager removeFavorite:favorite];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
@end
