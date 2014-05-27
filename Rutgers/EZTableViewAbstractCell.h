//
//  EZTableViewAbstractCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/23/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        11.0f

@interface EZTableViewAbstractCell : UITableViewCell
@property (nonatomic, assign) BOOL didSetupConstraints;
-(void)makeSubviews;
-(void)makeConstraints;
-(void)didLayoutSubviews;
@end
