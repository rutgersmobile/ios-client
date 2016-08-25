//
//  NSIndexPath+RowExtensions.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSIndexPath+RowExtensions.h"
/*
    An array of index paths from the given section from the given range
 */
@implementation NSIndexPath (RowExtensions)
+(NSArray *)indexPathsForRange:(NSRange)range inSection:(NSInteger)section{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = range.location; i < (range.location + range.length); i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    return indexPaths;
}
@end
