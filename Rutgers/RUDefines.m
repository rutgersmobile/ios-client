//
//  RUDefines.m
//  Rutgers
//
//  Created by Open Systems Solutions on 9/21/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

/*
    Determine whether a iPad is being used or an isBeta 
 
 
 */


#import <UIKit/UIKit.h>
#import "RUDefines.h"

BOOL iPad() {
    static bool iPad = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    });
    return iPad;
}

BOOL isBeta() {
    switch (betaMode) {
        case BetaModeDevelopment:
        case BetaModeBeta:
            return YES;
        case BetaModeProduction:
            return NO;
    }
}


NSString * betaModeString() {
    switch (betaMode) {
        case BetaModeDevelopment:
            return @"dev";
        case BetaModeBeta:
            return @"beta";
        case BetaModeProduction:
            return @"production";
    }
}