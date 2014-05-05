//
//  NSDictionary+FilterDictionary.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+FilterDictionary.h"

@implementation NSDictionary (FilterDictionary)
-(NSDictionary *)filteredDictionaryUsingPredicate:(NSPredicate *)predicate{
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([predicate evaluateWithObject:obj]) {
            returnDictionary[key] = obj;
        }
    }];
    return [returnDictionary copy];
}
@end
