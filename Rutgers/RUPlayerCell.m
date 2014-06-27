//
//  RUPlayerCardCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlayerCell.h"

#define IMAGE_PADDING 75

@interface RUPlayerCell ()

@end

@implementation RUPlayerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.opaque = YES;

        self.initialsLabel = [UILabel newAutoLayoutView];
        self.initialsLabel.textAlignment = NSTextAlignmentCenter;
        self.initialsLabel.font = [UIFont boldSystemFontOfSize:60];
        [self.contentView addSubview:self.initialsLabel];
        [self.initialsLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [self.initialsLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView withMultiplier:0.9];

        self.playerImageView = [UIImageView newAutoLayoutView];
        self.playerImageView.clipsToBounds = YES;
        self.playerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.playerImageView];

        [self.playerImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        self.nameLabel = [UILabel newAutoLayoutView];
        self.nameLabel.backgroundColor = [UIColor colorWithWhite:0.85 alpha:0.9];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.nameLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView withMultiplier:0.1];
        
    }
    return self;
}

@end
