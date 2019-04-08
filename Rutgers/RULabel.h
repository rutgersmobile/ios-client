//
//  RULabel.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


/*
  Descprit :
         Special type of UILabel doing what : 
 
 
 */
#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface RULabel : TTTAttributedLabel
@property (nonatomic) BOOL ignoresPreferredLayoutWidth;
@end
