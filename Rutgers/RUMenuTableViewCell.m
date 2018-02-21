//
//  RUMenuTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuTableViewCell.h" 
#import "RULabel.h"
#import "PureLayout.h"
#import "NSDictionary+Channel.h"
#import "UIFont+DynamicType.h"
#import "UIColor+RutgersColors.h"

@interface RUMenuTableViewCell ()
@property (nonatomic) NSDictionary *channel;
@end

@implementation RUMenuTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    return self;
}

-(void)initializeSubviews
{
    
    self.channelImage = [UIImageView newAutoLayoutView];
    self.channelImage.tintColor = [UIColor iconDeselectedColor];
    [self.contentView addSubview:self.channelImage];
    self.channelImage.contentMode = UIViewContentModeScaleAspectFit;
    
    self.channelTitleLabel = [RULabel newAutoLayoutView];
    self.channelTitleLabel.numberOfLines = 2;
    self.channelTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.contentView addSubview:self.channelTitleLabel];
    self.channelTitleLabel.textColor = [UIColor menuDeselectedColor];

}

-(void)initializeConstraints
{
    [self.channelImage autoSetDimensionsToSize:CGSizeMake(32, 32)];
    [self.channelImage autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:iPad() ? 20 : kLabelHorizontalInsets];
    [self.channelImage autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.channelTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.channelImage withOffset:kLabelHorizontalInsets];
    [self.channelTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets+3];
    [self.channelTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets+3 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.channelTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
}

-(void)updateFonts
{
    self.channelTitleLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
}

/*
    Methods are called from the data source did select row at index path
    
    Called when the user presses on a button on the menu slide view.
 
 */
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (!self.selected)
    {
        [super setHighlighted:highlighted animated:animated];
        [self applyStyleForHighlightedState:highlighted];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self applyStyleForHighlightedState:selected];
}

/*
    This function seems to over ride the configutation set up the setupForChannel :
        The ovverride happens for the image
 
 */
-(void)applyStyleForHighlightedState:(BOOL)state
{
    self.channelImage.tintColor = state ? [UIColor whiteColor] : [UIColor iconDeselectedColor];
    self.channelTitleLabel.textColor = state ? [UIColor whiteColor] : [UIColor menuDeselectedColor];
    self.backgroundColor = state ? [[UIColor blackColor] colorWithAlphaComponent:0.25] : nil;
    self.channelImage.image = state ? [self.channel filledChannelIcon] : [self.channel channelIcon];
}

/*
    Sets up a cell for displaying information about the channel that is being displayed by the user
 
 */
-(void)setupForChannel:(NSDictionary *)channel
{
    self.channel = channel;
    if(DEV) NSLog(@"Channel %@", channel);
    self.channelTitleLabel.text = [channel channelTitle];
    self.channelImage.image = [channel channelIcon];
}

/*
    Sets up the Menu Cell For displaying within the ru edit channel view controller in the options channel
 
 <q> 
    The image and the title are set up at some other location
 */
-(void)setupForChannelForEditOptions:(NSDictionary *)channel
{
    self.channel = channel;
    self.channelTitleLabel.text = @"test" ;//[channel channelTitle];
    [self.channelTitleLabel setTextColor:[UIColor blackColor]];
    self.channelImage.image = nil;
  //  self.channelImage.image = [channel channelIcon];
}

@end
