//
//  RUDebug.h
//  Rutgers
//
//  Created by scm on 9/29/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

/*
    Class with a few helper fucntioins for debugginng the view layout
 
 
    TO BE USED ONLY FOR TESTING WHETHER THE VIEWS ARE PROPERLY LAYED OUT
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/*
    Recursively travel down the view heirarcy and dump them out to console
 
 */

@interface RUDebug : NSObject

-(void) dumpView :(UIView *) aView atIndent:(int) indent;
@end




