//
//  UIColor+RutgersColors.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/14/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UIColor+RutgersColors.h"
#import <HexColors.h>

/*
    Category to hard code color functionality
 */

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

/*
    Color Used for the entire app
 */
+(UIColor *)rutgersBarRedColor{
    return [UIColor colorWithHue:0.97875000000000001 saturation:1 brightness:0.77607843137254897 alpha:1.0];
    // return [UIColor colorWithHue:0.97875000000000001 saturation:1 brightness:0.80607843137254897 alpha:1.0];

    // return [UIColor colorWithHexString:@"ca072d"];
    // return [UIColor colorWithHue:348.307678/360.0 saturation:0.96534653 brightness:0.80607843137254897 alpha:1.0];
}

@end
