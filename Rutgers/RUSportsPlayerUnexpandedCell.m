//
//  RUSportsPlayerDeselectedCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayerUnexpandedCell.h"
#import "RUSportsPlayerCell_Private.h"

@implementation RUSportsPlayerUnexpandedCell

-(void)updateFonts{
    [super updateFonts];
    self.positionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

-(void)initializeConstraints{
    [super initializeConstraints];
    
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:2];
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:2 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.playerView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.playerView];
    //[self.playerView autoSetDimensionsToSize:CGSizeMake(IMAGE_CLIPPED_HEIGHT, IMAGE_CLIPPED_HEIGHT)];
    
    [self.playerImageView autoSetDimensionsToSize:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT)];
    [self.playerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.playerImageView withOffset:SELECTED_IMAGE_TOP_CONSTRAINT];

}

@end
