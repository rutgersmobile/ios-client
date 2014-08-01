//
//  NSArray+SortByTitle.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSArray+SortByTitle.h"

@implementation NSArray (SortByTitle)
-(NSArray *)sortByTitle{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 title] compare:[obj2 title]];
    }];
}
@end
