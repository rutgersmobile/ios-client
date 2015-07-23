//
//  UIColor+RutgersColors.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/14/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UIColor+RutgersColors.h"

@implementation UIColor (RutgersColors)

+(UIColor *)rutgersRedColor{
    return [UIColor colorWithRed:203/255.0 green:11/255.0 blue:47/255.0 alpha:1];
}

+(UIColor *)rutgersGreyColor{
    return [UIColor colorWithRed:102/255.0 green:109/255.0 blue:112/255.0 alpha:1];
}

+(UIColor *)grey1Color{
    return [UIColor colorWithRed:45/255.0 green:51/255.0 blue:55/255.0 alpha:1];
}

+(UIColor *)grey2Color{
    return [UIColor colorWithRed:58/255.0 green:66/255.0 blue:71/255.0 alpha:1];
}

+(UIColor *)grey3Color{
    return [UIColor colorWithRed:63/255.0 green:74/255.0 blue:81/255.0 alpha:1];
}

+(UIColor *)grey4Color{
    return [UIColor colorWithRed:70/255.0 green:82/255.0 blue:89/255.0 alpha:1];
}

+(UIColor *)selectedRedColor{
    return [UIColor colorWithRed:221/255.0 green:44/255.0 blue:58/255.0 alpha:1];
}

+(UIColor *)menuDeselectedColor{
    return [UIColor colorWithWhite:0.85 alpha:1.0];
}

+(UIColor *)iconDeselectedColor{
    return [UIColor colorWithRed:177/255.0 green:198/255.0 blue:226/255.0 alpha:1];
}

+(UIColor *)rutgersBarRedColor{
    #warning aaron edit the final colors here
    //between 0 - 1
    return [UIColor colorWithHue:0.97875000000000001 saturation:1 brightness:0.79607843137254897 alpha:1.0];
   
    /*
    CGFloat hue, sat, bright, alpha;
    [[UIColor rutgersRedColor] getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    
    CGFloat hueFactor = 0.32;
    CGFloat satFactor = 1.0;
    
    hue = (hue + (1.0 - hue)*hueFactor);
    sat = (sat + (1.0 - sat)*satFactor);
    
    return [UIColor colorWithHue:hue saturation:sat brightness:bright alpha:alpha];
     */
}

@end
