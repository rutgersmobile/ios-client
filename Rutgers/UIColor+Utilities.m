//
//  UIColor+Modification.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/15/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "UIColor+Utilities.h"

@implementation UIColor (Utilities)
-(UIColor *)colorByMultiplyingSaturation:(CGFloat)saturationMultiplier andBrightness:(CGFloat)brightnessMultiplier{
    CGFloat hue, sat, bright, alpha;
    [self getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    sat *= saturationMultiplier;
    bright *= brightnessMultiplier;
    return [UIColor colorWithHue:hue saturation:sat brightness:bright alpha:alpha];
}
-(NSString *)colorTag{
    CGFloat hue, sat, bright, alpha;
    [self getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    return [NSString stringWithFormat:@"%f-%f-%f-%f", hue, sat, bright, alpha];
}
@end
