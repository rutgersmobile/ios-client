//
//  ALCollectionViewAbstractCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        11.0f

@interface ALCollectionViewAbstractCell : UICollectionViewCell
@property (nonatomic, assign) BOOL didSetupConstraints;
-(void)makeSubviews;
-(void)initializeConstraints;
-(void)didLayoutSubviews;
-(void)makeConstraintChanges;
@end
