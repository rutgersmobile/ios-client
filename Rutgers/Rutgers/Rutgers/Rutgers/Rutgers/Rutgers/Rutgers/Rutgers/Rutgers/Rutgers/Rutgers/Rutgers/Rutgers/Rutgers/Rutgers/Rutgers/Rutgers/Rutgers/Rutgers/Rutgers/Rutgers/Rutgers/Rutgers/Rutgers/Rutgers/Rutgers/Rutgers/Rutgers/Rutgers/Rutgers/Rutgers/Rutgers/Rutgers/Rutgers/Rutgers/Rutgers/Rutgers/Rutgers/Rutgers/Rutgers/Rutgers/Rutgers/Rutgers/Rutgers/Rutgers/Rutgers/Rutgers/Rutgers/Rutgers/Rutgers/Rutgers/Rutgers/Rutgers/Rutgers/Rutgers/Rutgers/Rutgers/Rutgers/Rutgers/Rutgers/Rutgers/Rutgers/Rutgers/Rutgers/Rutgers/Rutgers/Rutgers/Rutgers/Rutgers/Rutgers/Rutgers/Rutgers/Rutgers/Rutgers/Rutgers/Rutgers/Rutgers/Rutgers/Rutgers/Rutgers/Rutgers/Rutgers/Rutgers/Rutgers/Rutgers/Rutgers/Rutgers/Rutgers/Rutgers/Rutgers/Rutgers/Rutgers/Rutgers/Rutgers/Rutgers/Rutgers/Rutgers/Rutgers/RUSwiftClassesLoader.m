//
//  RUSwiftClassesLoader.m
//  Rutgers
//
//  Created by scm on 8/24/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUSwiftClassesLoader.h"

// To add the swift files to the channel manager
#import "RUChannelManager.h"

// To objtain the swift classes
#import "Rutgers-Swift.h"

/*
    Since swift does not have the "load" method called by its runtime like in objective c . We have to manually add each swift class we want to use to the RUChannelManager
 */
@implementation RUSwiftClassesLoader

/*
    The swift classes if there are being used as channels , then they will implemented the RUChannelProtocol and so we call the register method on them...
 
 
    // All swift classes we want the RUChannelManager to know about will be registered here
 */
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [RUEditMenuItemsViewController registerClass];
        
        
        
        
        
    });
}

@end
