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
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [RUSportsData getRosterForSportID:self.sportID withSuccess:^(NSArray *response) {
            [loading updateWithContent:^(typeof(self) me) {
                self.items = response;
            }];
        } failure:^{
            [loading doneWithError:nil];
        }];
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUSportsPlayerCell class] forCellReuseIdentifier:NSStringFromClass([RUSportsPlayerCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUSportsPlayerCell class]);
}

-(void)configureCell:(RUSportsPlayerCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    RUSportsPlayer *player = [self itemAtIndexPath:indexPath];
    
    cell.nameLabel.text = player.name;
    cell.jerseyNumberLabel.text = player.jerseyNumber;
    cell.initialsLabel.text = player.initials;
 
    cell.playerImageView.image = nil;
    [cell.playerImageView setImageWithURL:player.imageURL];
}

@end
