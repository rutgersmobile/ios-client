//
//  NSArray+LimitedToCount.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSArray+LimitedToCount.h"

@implementation NSArray (LimitedToCount)
-(NSArray *)limitedToCount:(NSUInteger)count{
    if (self.count <= count) return self;
    return [self subarrayWithRange:NSMakeRange(0, count)];
}
@end
