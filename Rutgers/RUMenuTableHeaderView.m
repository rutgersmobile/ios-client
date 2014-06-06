//
//  RUMenuTableHeaderView.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuTableHeaderView.h"


@implementation RUMenuTableHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initForAutoLayout];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.layer.masksToBounds = YES;
        
        
        self.imageView.layer.cornerRadius = MENU_HEADER_IMAGE_HEIGHT/2;
       
        [self.imageView autoSetDimensionsToSize:CGSizeMake(MENU_HEADER_IMAGE_HEIGHT, MENU_HEADER_IMAGE_HEIGHT)];
        
        [self addSubview:self.imageView];

        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8 relation:NSLayoutRelationGreaterThanOrEqual];
        
        self.nameLabel = [[UILabel alloc] initForAutoLayout];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
     
        self.detailLabel = [[UILabel alloc] initForAutoLayout];
        self.detailLabel.textColor = [UIColor whiteColor];
        self.detailLabel.font = [UIFont systemFontOfSize:13];
    
        [self addSubview:self.nameLabel];
        [self addSubview:self.detailLabel];

        [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.imageView withOffset:16];
        
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:16];
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8 relation:NSLayoutRelationGreaterThanOrEqual];
        
        [self.nameLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.detailLabel withOffset:0];
        [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.detailLabel withOffset:0];

        
        [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8 relation:NSLayoutRelationGreaterThanOrEqual];
        [self.detailLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8 relation:NSLayoutRelationGreaterThanOrEqual];
        
    }
    return self;
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
