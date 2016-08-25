//
//  NSAttributedString+FromHTML.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (FromHTML)
+(instancetype)attributedStringFromHTMLString:(NSString *)HTMLString preferedTextStyle:(NSString *)textStyle;
@end
