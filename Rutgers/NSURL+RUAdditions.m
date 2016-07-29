//
//  NSURL+RUAdditions.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/5/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "NSURL+RUAdditions.h"
#import "RUDefines.h"
#import "RUNetworkManager.h"

@implementation NSURL (RUAdditions)


/*
    pathComp... is an array of strings representing the point the app tghat we are at , 
 
    eg -> rutgers://bus/route/f/
    
    Safe to assume that there urls represent locations within the app hierarchy. 
    They are to distinguish / keep track / request the proper web information ?

 
 
*/
+(NSURL *)rutgersUrlWithPathComponents:(NSArray <NSString *>*)pathComponents{
//    NSMutableString *string = [NSMutableString stringWithString:@"http://rumobile.rutgers.edu/link/"];
    
    NSMutableString *string = [NSMutableString stringWithString:@"rutgers://"];
    for (NSString *component in pathComponents) {
        NSString *escapedComponent = component.rutgersStringEscape;
        [string appendFormat:@"%@/",escapedComponent];
    }
    return [NSURL URLWithString:string];
}

-(NSURL *)asRutgersURL {
    NSString* scheme = [self scheme];
    if ([scheme isEqualToString:@"rutgers"]) {
        return self;
    } else {
        // ["link", "handle", "rest", "of", "parts"]
        NSMutableArray* oldPathParts = [NSMutableArray arrayWithArray:[self pathComponents]];

        // ["handle", "rest", "of", "parts"]
        [oldPathParts removeObjectAtIndex:0];
        NSString* handle = oldPathParts[0];

        // ["rest", "of", "parts"]
        [oldPathParts removeObjectAtIndex:0];
        NSArray* pathComponents = [NSArray arrayWithArray:oldPathParts];

        // "rest/of/parts"
        NSString* path = [pathComponents componentsJoinedByString:@"/"];

        NSURLComponents* components = [NSURLComponents new];
        [components setScheme:@"rutgers"];
        [components setHost:handle];
        [components setPath:path];

        return [components URL];
    }
}

-(NSURL *)asHTTPURL {
    NSString* scheme = [self scheme];
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        return self;
    } else {
        // ["rest", "of", "parts"]
        NSMutableArray* oldPathParts = [NSMutableArray arrayWithArray:[self pathComponents]];
        NSString* handle = [self host];

        // ["handle", "rest", "of", "parts"]
        [oldPathParts insertObject:handle atIndex:0];

        // ["link", "handle", "rest", "of", "parts"]
        [oldPathParts insertObject:@"link" atIndex:0];

        NSArray* pathComponents = [NSArray arrayWithArray:oldPathParts];

        NSString* path = [pathComponents componentsJoinedByString:@"/"];

        NSURLComponents* components = [NSURLComponents
            componentsWithURL:[RUNetworkManager baseURL]
            resolvingAgainstBaseURL:NO
        ];
        [components setPath:path];

        return [components URL];
    }
}
@end

@implementation NSString (RUAdditions)
-(NSString *)rutgersStringEscape {
    return [[self stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end