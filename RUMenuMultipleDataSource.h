//
//  RUMenuMultipleDataSource.h
//  Rutgers
//
//  Created by scm on 5/31/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuBasicDataSource.h"

/*
    Holds Muliple Data Sources as a single Data Source
    This is the Data Source which will provide information to the Menu in the slide bar
    and the edit RUEditChanenl View Controller for the editing functionality wihtin the options channel
 */

@interface RUMenuMultipleDataSource : MenuBasicDataSource

+(instancetype) sharedManager;

-(id) objectAtIndex:(NSUInteger)index;

-(NSInteger) numberOfObjects;


@end
