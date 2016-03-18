//
//  NSURL+RUAdditions.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/5/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "NSURL+RUAdditions.h"
#import "RUDefines.h"

@implementation NSURL (RUAdditions)
+(NSURL *)rutgersUrlWithPathComponents:(NSArray <NSString *>*)pathComponents{
    NSMutableString *string = [NSMutableString stringWithString:@"rutgers://"];
    
    for (NSString *component in pathComponents) {
        NSString *escapedComponent = component.rutgersStringEscape;
        [string appendFormat:@"%@/",escapedComponent];
    }
    
    return [NSURL URLWithString:string];
}
@end

@implementation NSString (RUAdditions)
-(NSString *)rutgersStringEscape {
    return [[[self stringByRemovingPercentEncoding] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end