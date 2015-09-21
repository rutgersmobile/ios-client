//
//  EZTableViewAbstractCell.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/23/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUDefines.h"

@interface ALTableViewAbstractCell : UITableViewCell
@property (nonatomic, assign) BOOL didSetupConstraints;
-(void)initializeSubviews;
-(void)initializeConstraints;
-(void)updateFonts;
@end
