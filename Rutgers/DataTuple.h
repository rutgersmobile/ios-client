//
//  DataTuple.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This is a generic tuple, containing the title for an object, and a pointer to an object
 *  These can be used with the TupleDataSource to easily display them in a view controller
 *  and then on tap, get the object and use it to construct a new view controller to be pushed on the navigation stack
 */
@interface DataTuple : NSObject
-(instancetype)initWithTitle:(NSString *)title object:(id)object NS_DESIGNATED_INITIALIZER;
+(instancetype)tupleWithTitle:(NSString *)title object:(id)object;

@property NSString *title;
@property id object;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
@end
