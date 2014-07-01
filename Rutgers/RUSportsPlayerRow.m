//
//  RUSportsPlayerRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayerRow.h"
#import "RUSportsPlayer.h"
#import "RUSportsPlayerCell.h"
#import <UIKit+AFNetworking.h>

@interface RUSportsPlayerRow ()
@property (nonatomic) RUSportsPlayer *player;
@end

@implementation RUSportsPlayerRow
-(instancetype)initWithPlayer:(RUSportsPlayer *)player{
    self = [super initWithIdentifier:@"RUSportsPlayerCell"];
    if (self) {
        self.player = player;
    }
    return self;
}

-(void)setupCell:(RUSportsPlayerCell *)cell{
    cell.nameLabel.text = self.player.name;
    cell.jerseyNumberLabel.text = self.player.jerseyNumber;
    cell.initialsLabel.text = self.player.initials;
    cell.playerImageView.image = nil;
    [cell.playerImageView setImageWithURL:self.player.imageUrl];
}

@end
