//
//  RUMenuTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuTableViewCell.h" 
#import "RULabel.h"

@interface RUMenuTableViewCell ()
@end

@implementation RUMenuTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

-(void)initializeSubviews {
    
    self.channelImage = [UIImageView newAutoLayoutView];
    self.channelImage.tintColor = [UIColor iconDeselectedColor];
    [self.contentView addSubview:self.channelImage];
    self.channelImage.contentMode = UIViewContentModeTopLeft;
    
    self.channelTitleLabel = [RULabel newAutoLayoutView];
    self.channelTitleLabel.numberOfLines = 2;
    self.channelTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.contentView addSubview:self.channelTitleLabel];
    self.channelTitleLabel.textColor = [UIColor menuDeselectedColor];

}

-(void)initializeConstraints {
    [self.channelImage autoSetDimensionsToSize:CGSizeMake(32, 30)];
    [self.channelImage autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
    [self.channelImage autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.channelTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.channelImage withOffset:kLabelHorizontalInsets];
    [self.channelTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets+3];
    [self.channelTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets+3 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.channelTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
}

-(void)updateFonts{
    self.channelTitleLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
    [super setHighlighted:highlighted animated:animated];
    if (!self.selected) {
        [self applyStyleForHighlightedState:highlighted];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self applyStyleForHighlightedState:selected];
}

-(void)applyStyleForHighlightedState:(BOOL)state{
    self.channelImage.tintColor = state ? [UIColor whiteColor] : [UIColor iconDeselectedColor];
    self.channelTitleLabel.textColor = state ? [UIColor whiteColor] : [UIColor menuDeselectedColor];
    self.backgroundColor = state ? [[UIColor blackColor] colorWithAlphaComponent:0.25] : nil;
}


@end
