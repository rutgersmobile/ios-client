//
//  RUSportsPlayerSelectedCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayerExpandedCell.h"
#import "RUSportsPlayerCell_Private.h"
#import "RULabel.h"

@implementation RUSportsPlayerExpandedCell

-(void)initializeSubviews{
    [super initializeSubviews];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    /*
    self.bioButton = [UIButton newAutoLayoutView];
    [self.contentView addSubview:self.bioButton];
    
    self.bioButton.titleLabel.text = @"Bio";
    [self.bioButton sizeToFit];*/
    
    self.bioLabel = [RULabel newAutoLayoutView];
    self.bioLabel.numberOfLines = 3;
    
    [self.contentView addSubview:self.bioLabel];
    
    self.contentView.backgroundColor = [UIColor scarletRedColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.positionLabel.textColor = [UIColor whiteColor];
    self.jerseyNumberLabel.textColor = [UIColor whiteColor];
    self.bioLabel.textColor = [UIColor whiteColor];
}

-(void)updateFonts{
    [super updateFonts];
    self.positionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

-(void)initializeConstraints{
    [super initializeConstraints];
    
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:2 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.playerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:2 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.playerView autoSetDimensionsToSize:CGSizeMake(SELECTED_IMAGE_CLIPPED_WIDTH, SELECTED_IMAGE_CLIPPED_HEIGHT)];

    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];

    [self.positionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.playerView withOffset:kLabelHorizontalInsetsSmall];
    [self.positionLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.jerseyNumberLabel withOffset:-kLabelHorizontalInsetsSmall];
    [self.positionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameLabel withOffset:kLabelVerticalInsetsSmall];
    
    [self.bioLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.playerView withOffset:kLabelHorizontalInsetsSmall];
    [self.bioLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.jerseyNumberLabel withOffset:-kLabelHorizontalInsetsSmall];
    [self.bioLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.positionLabel withOffset:kLabelVerticalInsetsSmall];
    [self.bioLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    /*
    [self.bioButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.playerView withOffset:kLabelHorizontalInsetsSmall];
    [self.bioButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.positionLabel withOffset:kLabelVerticalInsetsSmall];
    [self.bioButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];*/

    [self.playerImageView autoSetDimensionsToSize:CGSizeMake(SELECTED_IMAGE_WIDTH, SELECTED_IMAGE_HEIGHT)];
    [self.playerView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.playerImageView withOffset:SELECTED_IMAGE_TOP_CONSTRAINT];

}

@end
