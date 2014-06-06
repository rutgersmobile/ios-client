//
//  RUMenuTableHeaderView.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MENU_HEADER_IMAGE_HEIGHT 54.0

@interface RUMenuTableHeaderView : UIView
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *detailLabel;
@end
