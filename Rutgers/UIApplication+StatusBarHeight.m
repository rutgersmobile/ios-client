//
//  UIApplication+StatusBarHeight.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UIApplication+StatusBarHeight.h"

@implementation UIApplication (StatusBarHeight)
-(CGFloat)statusBarHeight{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    return MIN(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame));
}
@end
