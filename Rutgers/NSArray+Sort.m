//
//  NSArray+SearchAndSort.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSArray+Sort.h"
#import "NSPredicate+SearchPredicate.h"

@implementation NSArray (Sort)

-(NSArray *)sortByKeyPath:(NSString *)keyPath{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKeyPath:keyPath] compare:[obj2 valueForKeyPath:keyPath] options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSNumericSearch];
    }];
}

-(NSArray *)sortByKeyPath:(NSString *)keyPath beginsWith:(NSString *)string{
    NSPredicate *beginsWithPredicate = [NSPredicate predicateWithFormat:@"%k beginswith[cd] %@",@"self",string];
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *valueOne = [obj1 valueForKeyPath:keyPath];
        NSString *valueTwo = [obj2 valueForKeyPath:keyPath];
        
        BOOL oneBeginsWith = [beginsWithPredicate evaluateWithObject:valueOne];
        BOOL twoBeingsWith = [beginsWithPredicate evaluateWithObject:valueTwo];
        
        if (oneBeginsWith && !twoBeingsWith) {
            return NSOrderedAscending;
        } else if (!oneBeginsWith && twoBeingsWith) {
            return NSOrderedDescending;
        } else {
            return [valueOne compare:valueTwo options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSNumericSearch];
        }
    }];
}


@end
