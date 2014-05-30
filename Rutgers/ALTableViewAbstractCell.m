//
//  EZTableViewAbstractCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/23/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewAbstractCell.h"

@implementation ALTableViewAbstractCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeSubviews];
    }
    return self;
}
-(void)makeSubviews{
    [NSException raise:@"You need to subclass EZTableViewAbstractCell and override the makeSubviews method" format:nil];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) return; // If constraints have been set, don't do anything.
    
    [self makeConstraints];
    
    self.didSetupConstraints = YES;
}
-(void)makeConstraints{
    [NSException raise:@"You need to subclass EZTableViewAbstractCell and override the makeConstraints method" format:nil];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutSubviews];
    
    [self didLayoutSubviews];
}
-(void)didLayoutSubviews{
    
}
@end
