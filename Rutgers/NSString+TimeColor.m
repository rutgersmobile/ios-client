//
//  NSString+TimeColor.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/2/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSString+TimeColor.h"
#import <HexColor.h>

@implementation NSString (TimeColor)
-(UIColor *)colorForMinutesString{
    NSInteger minutes = [self integerValue];
    if (minutes < 2) {
        return [UIColor colorWithHexString:@"#CC0000"];
    } else if (minutes < 6) {
        return [UIColor colorWithHexString:@"#FF6600"];
    } else {
        return [UIColor colorWithHexString:@"#000099"];
    }
}
@end
