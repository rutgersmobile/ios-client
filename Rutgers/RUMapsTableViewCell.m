//
//  MKTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsTableViewCell.h"
#import "RUEmbeddedMapsViewController.h"
#import <PureLayout.h>

@interface RUMapsTableViewCell ()
@property (nonatomic) UIView *controllerView;
@property (nonatomic) RUEmbeddedMapsViewController *mapsViewController;
@end

@implementation RUMapsTableViewCell

-(void)initializeSubviews{
    self.mapsViewController = [[RUEmbeddedMapsViewController alloc] init];
    self.controllerView = self.mapsViewController.view;
    [self.contentView addSubview:self.controllerView];
}

-(void)initializeConstraints{
    [self.controllerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.controllerView autoSetDimension:ALDimensionHeight toSize:[[self class] rowHeight] relation:NSLayoutRelationGreaterThanOrEqual];
    [self.controllerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
}

-(void)setPlace:(RUPlace *)place{
    self.mapsViewController.place = place;
}

+(CGFloat)rowHeight{
    return (iPad() ? round(180*IPAD_SCALE) : 180);
}

@end
