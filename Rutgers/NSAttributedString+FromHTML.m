//
//  NSAttributedString+FromHTML.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSAttributedString+FromHTML.h"

@implementation NSAttributedString (FromHTML)
+(instancetype)attributedStringFromHTMLString:(NSString *)HTMLString{
    NSDictionary *docattrs = nil;
    NSAttributedString *string = [[self alloc] initWithData:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
                                                              NSDefaultAttributesDocumentAttribute:
                                                                  @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}
                                                              }
                                         documentAttributes:&docattrs error:nil];
  
    return string;
}
@end
