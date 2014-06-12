//
//  RUReaderTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALTableViewAbstractCell.h"

#define IMAGE_WIDTH 62
#define IMAGE_HEIGHT 62
#define IMAGE_BOTTOM_PADDING 32

@interface RUReaderTableViewCell : ALTableViewAbstractCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageDisplayView;
@end
