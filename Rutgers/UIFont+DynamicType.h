//
//  UIFont+DynamicType.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (DynamicType)
+(UIFont *)preferredItalicFontForTextStyle:(NSString *)style;
+(UIFont *)preferredBoldFontForTextStyle:(NSString *)style;
+(CGFloat)preferredContentSizeScaleFactor;
@end
