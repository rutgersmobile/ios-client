//
//  RUNetworkManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "AFXMLResponseSerializer.h"
@interface RUNetworkManager ()
@property AFHTTPSessionManager *sessionManager;
@end

@implementation RUNetworkManager

/**
 *  The shared network manager acting as the main entry point for all network requests
 *
 *  @return The shared network manager instance
 */
+(RUNetworkManager *)sharedInstance{
    static RUNetworkManager *networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[RUNetworkManager alloc] init];
    });
    return networkManager;
}

+(AFHTTPSessionManager *)sessionManager{
    return [RUNetworkManager sharedInstance].sessionManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        jsonSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
        jsonSerializer.removesKeysWithNullValues = YES;
    
        AFXMLResponseSerializer *xmlSerializer = [AFXMLResponseSerializer serializer];
        xmlSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",@"text/xml",@"application/rss+xml",nil];
        
        NSString *urlString = @"https://rumobile.rutgers.edu/1/";
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
        self.sessionManager.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer,xmlSerializer]];
        self.sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
    }
    return self;
}
@end
