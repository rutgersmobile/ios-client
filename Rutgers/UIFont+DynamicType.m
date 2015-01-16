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

+(UIFont *)ruPreferredFontForTextStyle:(NSString *)style symbolicTraits:(UIFontDescriptorSymbolicTraits)symbolicTraits{
    UIFontDescriptor *descriptor = [[UIFontDescriptor preferredFontDescriptorWithTextStyle:style] fontDescriptorWithSymbolicTraits:symbolicTraits];
    CGFloat pointSize = descriptor.pointSize;
    return [UIFont fontWithDescriptor:descriptor size:(iPad() ? pointSize * IPAD_SCALE : pointSize)];
}

-(UIFont *)fontByScalingPointSize:(CGFloat)scalingRatio{
    return [self fontWithSize:self.fontDescriptor.pointSize*scalingRatio];
}
@end

