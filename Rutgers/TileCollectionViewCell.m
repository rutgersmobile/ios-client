//
//  EZCollectionViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TileCollectionViewCell.h"
#import "UIMotionEffect+FloatingMotionEffect.h"
#import "iPadCheck.h"
#import "RULabel.h"

@interface TileCollectionViewCell ()
@property (nonatomic) UIView *ellipsesView;
@property (nonatomic) NSLayoutConstraint *textBottomConstraint;
@end

@implementation TileCollectionViewCell


#define DOT_SIZE 5.5
#define DOT_PADDING 8.5
#define BOTTOM_PADDING (kLabelVerticalInsetsSmall+DOT_PADDING+DOT_SIZE)
#define FONT_STYLE (iPad() ? UIFontTextStyleBody : UIFontTextStyleSubheadline)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [RULabel newAutoLayoutView];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.textColor = [UIColor whiteColor];
        
        [self addSubview:self.ellipsesView];
        [self.ellipsesView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:DOT_PADDING];
        [self.ellipsesView autoAlignAxisToSuperviewAxis:ALAxisVertical];

        [self.contentView addSubview:self.textLabel];
        [self.textLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsetsSmall, kLabelHorizontalInsetsSmall, kLabelVerticalInsetsSmall, kLabelHorizontalInsetsSmall) excludingEdge:ALEdgeBottom];
        self.textBottomConstraint = [self.textLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:BOTTOM_PADDING];
        
        [self.textLabel addMotionEffect:[UIMotionEffect floatingMotionEffectWithIntensity:7]];
        [self.ellipsesView addMotionEffect:[UIMotionEffect floatingMotionEffectWithIntensity:3]];
        
        [self updateFonts];
    }
    return self;
}

-(void)updateFonts{
    self.textLabel.font = [UIFont preferredFontForTextStyle:FONT_STYLE];
}

-(void)setShowsEllipses:(BOOL)showsEllipses{
    _showsEllipses = showsEllipses;
    self.ellipsesView.hidden = !showsEllipses;
    self.textBottomConstraint.constant = showsEllipses ? -BOTTOM_PADDING : -kLabelVerticalInsetsSmall;
    [self.textLabel setNeedsLayout];
}

#define DOTS 3

-(UIView *)ellipsesView{
    if (!_ellipsesView) {
        UIView *ellipsesView = [UIView newAutoLayoutView];
        NSMutableArray *dots = [NSMutableArray array];
        for (int i = 0; i < DOTS; i++) {
            UIView *dotView = [self dotView];
            [dots addObject:dotView];
            [ellipsesView addSubview:dotView];
            [dotView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        }
        [dots autoDistributeViewsAlongAxis:ALAxisHorizontal withFixedSpacing:4.5 alignment:NSLayoutFormatAlignAllTop];
        _ellipsesView = ellipsesView;
    }
    return _ellipsesView;
}

-(UIView *)dotView{
    UIView *dot = [UIView newAutoLayoutView];
    [dot autoSetDimensionsToSize:CGSizeMake(DOT_SIZE, DOT_SIZE)];
    dot.backgroundColor = [UIColor whiteColor];
    dot.layer.cornerRadius = DOT_SIZE/2.0;
    return dot;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
