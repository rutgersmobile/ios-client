//
//  UIFont+DynamicType.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (DynamicType)

+(UIFont *)ruPreferredItalicFontForTextStyle:(NSString *)style;
+(UIFont *)ruPreferredBoldFontForTextStyle:(NSString *)style;
+(UIFont *)ruPreferredFontForTextStyle:(NSString *)style;
+(UIFont *)ruPreferredFontForTextStyle:(NSString *)style symbolicTraits:(UIFontDescriptorSymbolicTraits)symbolicTraits;
+(CGFloat)preferredContentSizeScaleFactor;
@end
