//
//  NSURL+RUAdditions.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/5/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "NSURL+RUAdditions.h"

@implementation NSURL (RUAdditions)
+(NSURL *)rutgersUrlWithPathComponents:(NSArray <NSString *>*)pathComponents{
    NSMutableString *string = [NSMutableString stringWithString:@"rutgers://"];
    
    for (NSString *component in pathComponents) {
        NSString *escapedComponent = [[component lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [string appendFormat: @"%@/", escapedComponent];
    }
    
    return [NSURL URLWithString:string];
}
@end
