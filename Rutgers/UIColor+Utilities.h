//
//  UIColor+Modification.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/15/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utilities)
-(UIColor *)colorByMultiplyingSaturation:(CGFloat)saturationMultiplier andBrightness:(CGFloat)brightnessMultiplier;
@property (nonatomic, readonly, copy) NSString *colorTag;
@end
