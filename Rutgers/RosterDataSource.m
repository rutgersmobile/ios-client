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
#import "RUSportsPlayerCell.h"
#import <UIKit+AFNetworking.h>

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
    [RUSportsData getRosterForSportID:self.sportID withSuccess:^(NSArray *response) {
        self.items = response;
    } failure:^{
        
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSportsPlayerCell class] forCellReuseIdentifier:NSStringFromClass([RUSportsPlayerCell class])];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSportsPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RUSportsPlayerCell class])];
    RUSportsPlayer *player = [self itemAtIndexPath:indexPath];
    
    cell.nameLabel.text = player.name;
    cell.jerseyNumberLabel.text = player.jerseyNumber;
    cell.initialsLabel.text = player.initials;
    cell.playerImageView.image = nil;
    [cell.playerImageView setImageWithURL:player.imageUrl];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

@end
