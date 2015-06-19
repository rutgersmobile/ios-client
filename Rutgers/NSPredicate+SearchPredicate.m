//
//  NSPredicate+SearchPredicate.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSPredicate+SearchPredicate.h"
#import "NSString+WordsInString.h"

@implementation NSPredicate (SearchPredicate)

+(NSArray *)subpredicatesForWords:(NSArray *)words keyPath:(NSString *)keyPath{
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    for (NSString *word in words) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(%K BEGINSWITH[cd] %@) OR (%K CONTAINS[cd] %@)", keyPath, word, keyPath,[NSString stringWithFormat:@" %@", word]];
        [predicates addObject:predicate];
    }
    
    return predicates;
}

+(NSPredicate *)predicateForQuery:(NSString *)query keyPath:(NSString *)keyPath{
    if (!query.length || !keyPath.length) return [NSPredicate predicateWithValue:NO];
    NSArray *wordsInQuery = [query wordsInString];
    if (!wordsInQuery.count) return [NSPredicate predicateWithValue:NO];
    return [NSCompoundPredicate andPredicateWithSubpredicates:[self subpredicatesForWords:wordsInQuery keyPath:keyPath]];
}

@end
