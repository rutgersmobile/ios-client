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


/*
    pathComp... is an array of strings representing the point the app tghat we are at , 
    or is it used as an url for the internet ?????
 
    eg -> rutgers://bus/route/f/
    
    Safe to assume that there urls represent locations within the app hierarchy. 
    They are to distinguish / keep track / request the proper web information ?

 
 
*/
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