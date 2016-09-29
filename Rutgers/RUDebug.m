//
//  RUDebug.m
//  Rutgers
//
//  Created by scm on 9/29/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUDebug.h"


@implementation RUDebug

-(void) dumpView :(UIView *) aView atIndent:(int) indent
{
    NSMutableString * outStr = [NSMutableString string];
    for( int i = 0 ; i < indent ; i++)
    {
        [outStr appendString:@"--"];
    }
   
    [outStr appendFormat:@"[%2d] %@\n" , indent ,[[aView class] description]];
   
    // print out to console
    NSLog(@"%@" , outStr);
    
    for( UIView * view in aView.subviews)
    {
        [self dumpView:view atIndent:indent + 1];
    }

}


@end
