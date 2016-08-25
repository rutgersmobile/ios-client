//
//  NSDictionary+ObjectsForKeys.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/11/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ObjectsForKeys)
-(NSArray *)objectsForKeysIgnoringNotFound:(NSArray *)keys;
@end
