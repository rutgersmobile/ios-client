//
//  RUReaderResponseSerializer.m
//  Rutgers
//
//  Created by Open Systems Solutions on 4/15/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUReaderResponseSerializer.h"

@implementation RUReaderResponseSerializer
-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    if ([NSString respondsToSelector:@selector(stringEncodingForData:encodingOptions:convertedString:usedLossyConversion:)]) {
        NSString *convertedString;
        [NSString stringEncodingForData:data encodingOptions:nil convertedString:&convertedString usedLossyConversion:nil];
        data = [convertedString dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [super responseObjectForResponse:response data:data error:error];
}
@end
