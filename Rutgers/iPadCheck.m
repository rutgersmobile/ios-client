//
//  iPadCheck.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "iPadCheck.h"

BOOL iPad() {
    static bool iPad = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    });
    return iPad;
}
