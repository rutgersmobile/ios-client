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
        
        self.playerImageView = [UIImageView newAutoLayoutView];
        self.playerImageView.clipsToBounds = YES;
        self.playerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.playerImageView];

        [self.playerImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        self.playerLabel = [UILabel newAutoLayoutView];
        self.playerLabel.backgroundColor = [UIColor colorWithWhite:0.85 alpha:0.9];
        self.playerLabel.adjustsFontSizeToFitWidth = YES;
        self.playerLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.playerImageView addSubview:self.playerLabel];
        [self.playerLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.playerLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.playerImageView withMultiplier:0.1];
        
    }
    return self;
}

@end
