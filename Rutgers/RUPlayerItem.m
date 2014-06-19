//
//  RUPlayerCardItem.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlayerItem.h"
#import "RUSportsPlayer.h"
#import "RUPlayerCell.h"
#import <UIKit+AFNetworking.h>

@interface RUPlayerItem ()
@property (nonatomic) RUSportsPlayer *player;
@end

@implementation RUPlayerItem
- (instancetype)init
{
    return [super initWithIdentifier:@"RUPlayerCardCell"];
}

-(instancetype)initWithSportsPlayer:(RUSportsPlayer *)player{
    self = [self init];
    if (self) {
        self.player = player;
    }
    return self;
}

-(void)setupCell:(RUPlayerCell *)cell{
    cell.nameLabel.text = self.player.name;
    cell.initialsLabel.text = self.player.initials;
    cell.playerImageView.image = nil;
    
    if (self.player.imageUrl) {
        [cell.playerImageView setImageWithURL:self.player.imageUrl];
    }
}

@end
