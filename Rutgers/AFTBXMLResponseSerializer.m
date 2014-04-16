//
//  AFTBXMLResponseSerializer.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "AFTBXMLResponseSerializer.h"
#import "TBXML-Headers/TBXML.h"

@implementation AFTBXMLResponseSerializer
- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if ([(NSError *)(*error) code] == NSURLErrorCannotDecodeContentData) {
            return nil;
        }
    }
    return [TBXML newTBXMLWithXMLData:data error:error];
    //    return [[TBXML alloc] initWithData:data];
}
@end
