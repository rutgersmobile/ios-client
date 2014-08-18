 //
//  NSArray+SearchAndSort.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSArray+Sort.h"
#import "NSPredicate+SearchPredicate.h"
#import "NSString+Score.h"

@implementation NSArray (Sort)

-(NSArray *)sortByKeyPath:(NSString *)keyPath{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKeyPath:keyPath] compare:[obj2 valueForKeyPath:keyPath] options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSNumericSearch];
    }];
}

-(NSArray *)sortByKeyPath:(NSString *)keyPath forQuery:(NSString *)query{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *stringOne = [obj1 valueForKeyPath:keyPath];
        NSString *stringTwo = [obj2 valueForKeyPath:keyPath];
        
        CGFloat scoreOne = [stringOne scoreAgainst:query];
        CGFloat scoreTwo = [stringTwo scoreAgainst:query];
        
        if (scoreOne < scoreTwo) return NSOrderedAscending;
        else if (scoreOne > scoreTwo) return NSOrderedDescending;
        
        return [stringOne compare:stringTwo options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSNumericSearch];
    }];
}

@end
