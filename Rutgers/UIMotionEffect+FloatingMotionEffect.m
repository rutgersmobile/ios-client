//
//  UIMotionEffect+TileMotionEffect.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UIMotionEffect+FloatingMotionEffect.h"

CGFloat deg2rad (CGFloat degrees) {
    return degrees * M_PI / 180.0;
}

@implementation UIMotionEffect (FloatingMotionEffect)
+(instancetype)floatingMotionEffectWithIntensity:(CGFloat)intensity{
    UIMotionEffectGroup *tileMotionEffect = [[UIMotionEffectGroup alloc] init];

    
    UIInterpolatingMotionEffect *verticalCenter = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalCenter.maximumRelativeValue = @(intensity);
    verticalCenter.minimumRelativeValue =  @(-intensity);
    
    UIInterpolatingMotionEffect *horizontalCenter = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalCenter.maximumRelativeValue = @(intensity);
    horizontalCenter.minimumRelativeValue =  @(-intensity);
    
    [tileMotionEffect setMotionEffects:@[verticalCenter,horizontalCenter]];

    return tileMotionEffect;
}
/*
NSValue * skew (CGFloat amount, CGFloat x, CGFloat y, CGFloat z)
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0f / 1000.0;
    return [NSValue valueWithCATransform3D:CATransform3DMakeRotation((amount * M_PI / 180.0f), x, y, z)];
}*/
@end
