//
//  NSDictionary+FilterDictionary.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FilterDictionary)
-(NSDictionary *)filteredDictionaryUsingPredicate:(NSPredicate *)predicate;
@end
