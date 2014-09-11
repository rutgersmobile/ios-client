//
//  UIFont+DynamicType.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "UIFont+DynamicType.h"

@implementation UIFont (DynamicType)
+(UIFont *)ruPreferredItalicFontForTextStyle:(NSString *)style{
    return [self ruPreferredFontForTextStyle:style symbolicTraits:UIFontDescriptorTraitItalic];
}

+(UIFont *)ruPreferredBoldFontForTextStyle:(NSString *)style{
    return [self ruPreferredFontForTextStyle:style symbolicTraits:UIFontDescriptorTraitBold];
}

+(UIFont *)ruPreferredFontForTextStyle:(NSString *)style{
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];
    CGFloat pointSize = descriptor.pointSize;
    return [UIFont fontWithDescriptor:descriptor size:(iPad() ? pointSize * IPAD_SCALE : pointSize)];
}

+(UIFont *)ruPreferredFontForTextStyle:(NSString *)style symbolicTraits:(UIFontDescriptorSymbolicTraits)symbolicTraits{
    UIFontDescriptor *descriptor = [[UIFontDescriptor preferredFontDescriptorWithTextStyle:style] fontDescriptorWithSymbolicTraits:symbolicTraits];
    CGFloat pointSize = descriptor.pointSize;
    return [UIFont fontWithDescriptor:descriptor size:(iPad() ? pointSize * IPAD_SCALE : pointSize)];
}

//stuff below here isnt used yet
+(CGFloat)preferredContentSizeScaleFactor{
    NSString *contentSizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;
    NSString *defaultSizeCategory = UIContentSizeCategoryLarge;
    
    CGFloat currentScale = [self scaleForContentSize:contentSizeCategory];
    CGFloat defaultScale = [self scaleForContentSize:defaultSizeCategory];
    
    return currentScale/defaultScale;
}

+(CGFloat)scaleForContentSize:(NSString *)contentSizeCategory{
    static NSDictionary *mappings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mappings = @{
                     UIContentSizeCategoryExtraSmall : @(10),
                     UIContentSizeCategorySmall : @(10),
                     UIContentSizeCategoryMedium : @(10),
                     UIContentSizeCategoryLarge : @(10),
                     UIContentSizeCategoryExtraLarge : @(10),
                     UIContentSizeCategoryExtraExtraLarge : @(10),
                     UIContentSizeCategoryExtraExtraExtraLarge : @(10),
                     UIContentSizeCategoryAccessibilityMedium : @(10),
                     UIContentSizeCategoryAccessibilityLarge : @(10),
                     UIContentSizeCategoryAccessibilityExtraLarge : @(10),
                     UIContentSizeCategoryAccessibilityExtraExtraLarge : @(10),
                     UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @(10),
                     };
    });
    
    return [mappings[contentSizeCategory] doubleValue];
}
@end

