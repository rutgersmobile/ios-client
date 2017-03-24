//
//  RUThankMrSOC.m
//  Rutgers
//
//  Created by Matt Robinson on 3/20/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONKit/JSONKit.h>
#import "RUThankMrSOC.h"

@implementation RUThankMrSOC

+(id)objectFromJSONData:(NSData*)data {
    NSString* latin1Data = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    return [latin1Data objectFromJSONString];
}

@end
