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
+(RUNetworkManager *)sharedInstance{
    static RUNetworkManager *networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[RUNetworkManager alloc] init];
    });
    return networkManager;
}

+(AFHTTPSessionManager *)jsonSessionManager{
    return [RUNetworkManager sharedInstance].jsonSessionManager;
}
+(AFHTTPSessionManager *)xmlSessionManager{
    return [RUNetworkManager sharedInstance].xmlSessionManager;
}
+(AFHTTPSessionManager *)HTTPSessionManager{
    return [RUNetworkManager sharedInstance].HTTPSessionManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.jsonSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://rumobile.rutgers.edu/1/"]];
        self.jsonSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.jsonSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",nil];
    
        self.xmlSessionManager = [AFHTTPSessionManager manager];
        self.xmlSessionManager.responseSerializer = [AFXMLResponseSerializer serializer];
        self.xmlSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",@"text/xml",@"application/rss+xml",nil];
        
        self.HTTPSessionManager = [AFHTTPSessionManager manager];
        
    }
    return self;
}
@end
