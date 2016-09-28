//
//  NSMutableArray+Queue.h
//  Rutgers
//
//  Created by scm on 9/27/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    Warning : Do not use for large queue sizes . The deque operation is O(n)
 */

@interface NSMutableArray (RUQueue)
-(id) dequeue ;
-(void) enqueue :(id) obj ;
@end
