//
//  AFXMLResponseSerializer.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "AFXMLResponseSerializer.h"
#import "XMLDictionary.h"
@implementation AFXMLResponseSerializer
- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if ([(NSError *)(*error) code] == NSURLErrorCannotDecodeContentData) {
            return nil;
        }
    }
    XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
    parser.alwaysUseArrays = YES;
    parser.stripEmptyNodes = YES;
    
    return [parser dictionaryWithData:data];
}
@end
