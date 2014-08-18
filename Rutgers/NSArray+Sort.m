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

@end
