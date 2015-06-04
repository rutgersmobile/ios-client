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
    return [self ruPreferredFontForTextStyle:style symbolicTraits:0];
}

-(UIFont *)fontByScalingPointSize:(CGFloat)scalingRatio{
    return [self fontWithSize:self.fontDescriptor.pointSize*scalingRatio];
}

+(UIFont *)ruPreferredFontForTextStyle:(NSString *)style symbolicTraits:(UIFontDescriptorSymbolicTraits)symbolicTraits{
    static NSMutableDictionary *fontCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontCache = [NSMutableDictionary dictionary];
    });
    
    NSString *sizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    NSMutableDictionary *cacheForSize = fontCache[sizeCategory];
    if (!cacheForSize) {
        cacheForSize = [NSMutableDictionary dictionary];
        fontCache[sizeCategory] = cacheForSize;
    }
    
    NSMutableDictionary *cacheForStyle = cacheForSize[style];
    if (!cacheForStyle) {
        cacheForStyle = [NSMutableDictionary dictionary];
        cacheForSize[style] = cacheForStyle;
    }
    
    UIFont *font = cacheForStyle[@(symbolicTraits)];
    if (!font) {
        UIFontDescriptor *descriptor = [[UIFontDescriptor preferredFontDescriptorWithTextStyle:style] fontDescriptorWithSymbolicTraits:symbolicTraits];
        CGFloat pointSize = descriptor.pointSize;
        font = [UIFont fontWithDescriptor:descriptor size:(iPad() ? pointSize * IPAD_SCALE : pointSize)];
        cacheForStyle[@(symbolicTraits)] = font;
    }
    
    return font;
}
@end

