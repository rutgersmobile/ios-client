//
//  RUNetworkManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUResponseSerializer.h"
#import "RUReaderResponseSerializer.h"

@interface RUNetworkManager ()
@property AFHTTPSessionManager *sessionManager;
@end

@implementation RUNetworkManager

/**
 *  The shared network manager acting as the main entry point for all network requests
 *
 *  @return The shared network manager instance
 */

+(AFHTTPSessionManager *)baseManager{
    
    NSString *baseUrl = @"https://rumobile.rutgers.edu/";
    if (BETA) baseUrl = @"https://doxa.rutgers.edu/mobile/";
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",baseUrl,api]]];
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
  //  if (BETA) manager.securityPolicy.allowInvalidCertificates = YES;
    
    return manager;
}


+(AFHTTPSessionManager *)sessionManager{
    static AFHTTPSessionManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [self baseManager];
        sessionManager.responseSerializer = [RUResponseSerializer compoundResponseSerializer];
    });
    return sessionManager;
}

+(AFHTTPSessionManager *)readerSessionManager{
    static AFHTTPSessionManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [self baseManager];
        sessionManager.responseSerializer = [RUReaderResponseSerializer compoundResponseSerializer];
    });
    return sessionManager;
}

@end
