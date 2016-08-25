//
//  RUReaderTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALTableViewAbstractCell.h"



@interface RUReaderTableViewCell : ALTableViewAbstractCell
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageDisplayView;
@property (nonatomic) BOOL hasImage;
@end
