//
//  NSString+SHA1.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSString+SHA1.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SHA1)
- (uint64_t)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    uint64_t returnValue = 0;
    
    for (int i = 0; i < 8; i++) {
        returnValue += (((uint64_t)digest[i]) << i*8);
    }
    
    return returnValue;
}
@end
