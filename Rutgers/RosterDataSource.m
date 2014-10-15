//
//  RosterDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RosterDataSource.h"
#import "RUSportsData.h"
#import "RUSportsPlayer.h"
#import "RUSportsPlayerExpandedCell.h"
#import "RUSportsPlayerUnexpandedCell.h"
#import <UIKit+AFNetworking.h>
#import "DataSource_Private.h"

@interface RosterDataSource ()
@property RUSportsPlayer *expandedPlayer;
@end

@implementation RosterDataSource
-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.title = @"Roster";
        self.sportID = sportID;
    }
    return self;
}

-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [RUSportsData getRosterForSportID:self.sportID withSuccess:^(NSArray *response) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            [loading updateWithContent:^(typeof(self) me) {
                self.items = response;
            }];
        } failure:^{
            if (!loading.current) {
                [loading ignore];
                return;
            }
            [loading doneWithError:nil];
        }];
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSportsPlayerExpandedCell class] forCellReuseIdentifier:NSStringFromClass([RUSportsPlayerExpandedCell class])];
    [tableView registerClass:[RUSportsPlayerUnexpandedCell class] forCellReuseIdentifier:NSStringFromClass([RUSportsPlayerUnexpandedCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSportsPlayer *player = [self itemAtIndexPath:indexPath];
    return NSStringFromClass([player isEqual:self.expandedPlayer] ? [RUSportsPlayerExpandedCell class] :[RUSportsPlayerUnexpandedCell class]);
}

-(void)toggleExpansionForPlayer:(RUSportsPlayer *)player{
    RUSportsPlayer *lastExpandedPlayer = self.expandedPlayer;
    self.expandedPlayer = player;
    
    NSArray *indexPaths;
    
    if ([player isEqual:lastExpandedPlayer]){
        _expandedPlayer = nil;
        indexPaths = [self indexPathsForItem:player];
    } else {
        indexPaths = [[self indexPathsForItem:player] arrayByAddingObjectsFromArray:[self indexPathsForItem:lastExpandedPlayer]];
    }
    
    [self invalidateCachedHeightsForIndexPaths:indexPaths];
    [self notifyItemsRefreshedAtIndexPaths:indexPaths];
}

-(void)configureCell:(RUSportsPlayerCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSportsPlayer *player = [self itemAtIndexPath:indexPath];
    
    cell.nameLabel.text = player.name;
    cell.jerseyNumberLabel.text = player.jerseyNumber;
    cell.initialsLabel.text = player.initials;
    cell.positionLabel.text = player.position;

    cell.playerImageView.image = nil;
    [cell.playerImageView setImageWithURL:player.imageURL];
    

    if ([cell isKindOfClass:[RUSportsPlayerExpandedCell class]]) {
        RUSportsPlayerExpandedCell *expandedCell = (RUSportsPlayerExpandedCell *)cell;
        expandedCell.bioLabel.attributedText = player.bio;
       // expandedCell.positionLabel.text = player.position;
    }
}

@end
