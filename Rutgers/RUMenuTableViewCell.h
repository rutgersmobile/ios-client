//
//  RUMenuTableViewCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBShimmeringView.h>

@interface RUMenuTableViewCell : UITableViewCell
@property (nonatomic) UILabel *channelTitleLabel;
@property (nonatomic) UIImageView *channelImage;
@property (nonatomic) FBShimmeringView *shimmeringView;
@end
