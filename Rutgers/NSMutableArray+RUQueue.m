//
//  NSMutableArray+Queue.m
//  Rutgers
//
//  Created by scm on 9/27/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "NSMutableArray+RUQueue.h"

@implementation NSMutableArray (RUQueue)

// Queues are first in first out , objects removed from the head
/*
    Produces exception when try to deque item when there are not objects in it 
 */
-(id) dequeue
{
    id headObj = [self objectAtIndex:0];
    if(headObj != nil)
    {
        [self removeObjectAtIndex:0];
    }
    
    return headObj;
}


-(void)enqueue:(id)obj
{
    [self addObject:obj];
}


@end

/*
    Reason for adding : 
        To implment an exception queue for RUAnalytics
 */
