//
//  EZCollectionViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewCell.h"

@interface EZCollectionViewCell ()
@property (nonatomic) UIView *ellipsesView;
@end

@implementation EZCollectionViewCell

#define PADDING 6

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[UILabel alloc] initForAutoLayout];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.textLabel];
        [UIView autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
            [self.textLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING)];
        }];
    }
    return self;
}
-(void)setShowsEllipses:(BOOL)showsEllipses{
    if (_showsEllipses && !showsEllipses) {
        //hide ellipses
        [self.ellipsesView removeFromSuperview];
    } else if (!_showsEllipses && showsEllipses) {
        //show ellipses
        [self addSubview:self.ellipsesView];
        [self.ellipsesView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textLabel withOffset:PADDING relation:NSLayoutRelationGreaterThanOrEqual];
        [self.ellipsesView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8.5];
        [self.ellipsesView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    }
    _showsEllipses = showsEllipses;

}
#define DOTS 3

-(UIView *)ellipsesView{
    if (!_ellipsesView) {
        UIView *ellipsesView = [[UIView alloc] initForAutoLayout];
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
#define DOT_SIZE 5.5
-(UIView *)dotView{
    UIView *dot = [[UIView alloc] initForAutoLayout];
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
