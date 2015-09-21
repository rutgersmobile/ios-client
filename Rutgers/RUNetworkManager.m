//
//  RUNetworkManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUResponseSerializer.h"
#import "RUReaderResponseSerializer.h"
#import "RUNetworkManager.h"
#import "RUDefines.h"

@interface RUNetworkManager ()
@property AFHTTPSessionManager *sessionManager;
@end

@implementation RUNetworkManager

/**
 *  The shared network manager acting as the main entry point for all network requests
 *
 *  @return The shared network manager instance
 */

+(NSURL *)baseURL{
    NSString *baseUrl = @"https://rumobile.rutgers.edu/";
    
    #warning todo get nstanlee url
    switch (betaMode) {
        case BetaModeDevelopment:
            baseUrl = @"http://192.168.160.226/~gts37/mobile/";
            break;
        case BetaModeBeta:
            baseUrl = @"https://doxa.rutgers.edu/mobile/";
            break;
        default:
            break;
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",baseUrl,api]];
}

+(AFHTTPSessionManager *)baseManager{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
  //  if (BETA) manager.securityPolicy.allowInvalidCertificates = YES;
    return manager;
}

+(AFHTTPSessionManager *)backgroundSessionManager{
    static AFHTTPSessionManager *backgroundSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = nil;
        NSString *identifier = @"Analytics BG";
        
        if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        } else {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
        }
        
        backgroundSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL] sessionConfiguration:configuration];
        backgroundSessionManager.responseSerializer = [RUResponseSerializer compoundResponseSerializer];
    });
    return backgroundSessionManager;
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
