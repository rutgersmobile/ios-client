//
//  NSString+WordsInString.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSString+WordsInString.h"

@implementation NSString (WordsInString)
-(NSArray *)wordsInString{
    NSMutableArray *words = [NSMutableArray array];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [words addObject:substring];
    }];
    NSLog(@"%@",words);
    return words;
}

@end