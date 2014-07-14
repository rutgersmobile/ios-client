//
//  RUNetworkManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNetworkManager.h"
#import "AFXMLResponseSerializer.h"
@interface RUNetworkManager ()
@property AFHTTPSessionManager *jsonSessionManager;
@property AFHTTPSessionManager *xmlSessionManager;
@property AFHTTPSessionManager *HTTPSessionManager;
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

/**
 *  The session manager specializing in json, defaulting to load off the rutgers mobile servers if only given a path fragment
 *  Parses the response using NSJSONSerialization
 *
 *  @return The json session manager
 */
+(AFHTTPSessionManager *)jsonSessionManager{
    return [RUNetworkManager sharedInstance].jsonSessionManager;
}

/**
 *  The session manager specializing in xml
 *  Parses the response using XMLDictionary
 *
 *  @return The xml session manager
 */
+(AFHTTPSessionManager *)xmlSessionManager{
    return [RUNetworkManager sharedInstance].xmlSessionManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.jsonSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://rumobile.rutgers.edu/1/"]];
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        jsonSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",nil];
        jsonSerializer.removesKeysWithNullValues = YES;
        self.jsonSessionManager.responseSerializer = jsonSerializer;
    
        self.xmlSessionManager = [AFHTTPSessionManager manager];
        self.xmlSessionManager.responseSerializer = [AFXMLResponseSerializer serializer];
        self.xmlSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",@"text/xml",@"application/rss+xml",nil];
    }
    return self;
}
@end
