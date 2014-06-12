//
//  MKTableViewCell.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "MKTableViewCell.h"
#import "RUMapsViewController.h"
@interface MKTableViewCell ()
@property (nonatomic) RUMapsViewController *mapsViewController;
@property (nonatomic) UIView *controllerView;
@end
@implementation MKTableViewCell

-(void)makeSubviews{
    self.mapsViewController = [[RUMapsViewController alloc] init];
    self.controllerView = self.mapsViewController.view;
    self.controllerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.controllerView];
}

-(void)initializeConstraints{
    [self.controllerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [self.controllerView autoSetDimension:ALDimensionHeight toSize:200];
}

-(void)makeConstraintChanges{
    
}

@end
