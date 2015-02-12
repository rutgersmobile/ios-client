//
//  NSAttributedString+FromHTML.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSAttributedString+FromHTML.h"
#import <NSString+HTML.h>

@implementation NSAttributedString (FromHTML)
/**
 *  <#Description#>
 *
 *  @param HTMLString <#HTMLString description#>
 *  @param textStyle  <#textStyle description#>
 *
 *  @return <#return value description#>
 */
+(instancetype)attributedStringFromHTMLString:(NSString *)HTMLString preferedTextStyle:(NSString *)textStyle{
    NSDictionary *docattrs = nil;
    
    HTMLString = [HTMLString stringByDecodingHTMLEntities];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"<p>&nbsp;</p>" withString:@""];

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithData:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                         documentAttributes:&docattrs error:nil];
    
    //[string.mutableString replaceOccurrencesOfString:@" \n" withString:@"\n" options:0 range:NSMakeRange(0, string.length)];
    //[string.mutableString replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:0 range:NSMakeRange(0, string.length)];
    
    [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs[NSBackgroundColorAttributeName]) [string removeAttribute:NSBackgroundColorAttributeName range:range];
        UIFont *font = attrs[NSFontAttributeName];
        UIFont *preferredFont = [UIFont ruPreferredFontForTextStyle:textStyle symbolicTraits:font.fontDescriptor.symbolicTraits];
        [string addAttributes:@{NSFontAttributeName : preferredFont} range:range];
    }];

    CFStringTrimWhitespace((CFMutableStringRef)string.mutableString);
    
    return string;
}
@end
