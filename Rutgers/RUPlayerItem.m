//
//  RUPlayerCardItem.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlayerItem.h"
#import "RUPlayerCell.h"
#import <UIKit+AFNetworking.h>

@interface RUPlayerItem ()
@property NSDictionary *playerInfo;
@end

@implementation RUPlayerItem
- (instancetype)init
{
    self = [super initWithIdentifier:@"RUPlayerCardCell"];
    if (self) {
        
    }
    return self;
}
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [self init];
    if (self) {
        self.playerInfo = dictionary;
    }
    return self;
}

-(void)setupCell:(RUPlayerCell *)cell{
    cell.playerLabel.text = [self.playerInfo[@"fullName"] firstObject];
    [cell.playerImageView setImageWithURL:[self imageURL] placeholderImage:[UIImage imageNamed:@"ABPicturePerson"]];
    
}
-(NSURL *)imageURL{
    return [NSURL URLWithString:[self.playerInfo[@"image"] firstObject]];
}
@end
