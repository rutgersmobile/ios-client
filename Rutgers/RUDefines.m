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

BOOL iPad()
{
    static bool iPad = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    });
    return iPad;
}

BOOL isBeta()
{
    switch (runMode)
    {
        case LocalDevMode:
        case AlphaMode:
        case BetaMode:
            return YES;
        case ProductionMode:
            return NO;
    }
}


NSString * betaModeString() {
    switch (runMode)
    {
        case LocalDevMode:
            return @"local dev mode";
        case AlphaMode:
            return @"alpha mode";
        case BetaMode:
            return @"beta mode";
        case ProductionMode:
            return @"production mode";
    }
}


/*
 Takes in an NSURL and returns the absolute string for that URL
 Without the RU , the name conflicts with internal apple function
 */
NSString * RUGetAbsoluteString(NSURL * url)
{
    return url.absoluteString;
}



