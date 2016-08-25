//
//  NSDictionary+ObjectsForKeys.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/11/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+ObjectsForKeys.h"

@implementation NSDictionary (ObjectsForKeys)
-(NSArray *)objectsForKeysIgnoringNotFound:(NSArray *)keys{
    NSArray *objects = [self objectsForKeys:keys notFoundMarker:[NSNull null]];
    return  [objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {return ![obj isEqual:[NSNull null]];}]];
}
@end
