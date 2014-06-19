//
//  MKTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsTableViewCell.h"
#import "RUEmbeddedMapsViewController.h"
@interface RUMapsTableViewCell ()
@property (nonatomic) UIView *controllerView;
@property (nonatomic) RUEmbeddedMapsViewController *mapsViewController;
@end

@implementation RUMapsTableViewCell

-(void)makeSubviews{
    self.mapsViewController = [[RUEmbeddedMapsViewController alloc] init];
    self.controllerView = self.mapsViewController.view;
    [self.contentView addSubview:self.controllerView];
}

-(void)initializeConstraints{
    [self.controllerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [UIView autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
        [self.controllerView autoSetDimension:ALDimensionHeight toSize:180 relation:NSLayoutRelationGreaterThanOrEqual];
    }];

}

-(void)setPlace:(RUPlace *)place{
    self.mapsViewController.place = place;
}

@end
