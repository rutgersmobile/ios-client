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

/*
 Two seprate request :
 One to rutgers : rumobile.ru--.edu to get the configuration files , the other request is send to next bus to obtain the
 timings .
 
 */

/**
 *  The shared network manager acting as the main entry point for all network requests
 *
 * Base url acts as base for using relavtive url
 *
 *  @return The shared network manager instance
 */

+(NSURL *)baseURL{
    NSString * baseUrl  ;
    
    switch (runMode)
    {
        case LocalDevMode:
            baseUrl = @"http://localhost/";
            break;
        case AlphaMode:
            baseUrl = @"http://nstanlee.rutgers.edu/4";
            //            baseUrl = @"http://rumobile-gis-prod-asb.ei.rutgers.edu";
            break;
        case BetaMode:
            baseUrl = @"https://doxa.rutgers.edu/mobile/";
            break;
        case ProductionMode:
            baseUrl = @"https://rumobile.rutgers.edu/";
            break;
        default:
            break;
    }
    
    //NSLog(@"Base URL : %@ " , baseUrl);
    baseUrl = [baseUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Base URL : %@ " , baseUrl);
    
    //    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",baseUrl,api]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@",baseUrl]];
    
}

/*
 Sets up the manager with our base URL. This tells Afnetworking to go our servers.
 For each request we append the particular thing we are looking for and obtain the result.
 restful api
 */
+(AFHTTPSessionManager *)baseManager
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
    
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    //if (BETA) manager.securityPolicy.allowInvalidCertificates = YES;
    return manager;
}

/*
 A single session maanger is used to handle the http request through out the app
 
 */
+(AFHTTPSessionManager *)backgroundSessionManager
{
    static AFHTTPSessionManager *backgroundSessionManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      // set up at networking with the base url
                      backgroundSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
                      
                      // provide serializer to the manager : Which gives us inforamtion on how to parse the response object
                      // json and xml parsers
                      backgroundSessionManager.responseSerializer = [RUResponseSerializer compoundResponseSerializer];
                      
                  });
    
    return backgroundSessionManager;
}

/*
 Build from the base manager but has additional serialization options..
 So the repsonse will be serialized using xml or json parsers
 */
+(AFHTTPSessionManager *)sessionManager
{
    static AFHTTPSessionManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ // ensure that this is executed only once
                  {
                      sessionManager = [self baseManager]; // build on top of the base manager
                      sessionManager.responseSerializer = [RUResponseSerializer compoundResponseSerializer];
                  });
    return sessionManager;
}

+(AFHTTPSessionManager*)transLocSessionManager {
    AFHTTPSessionManager*  manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField: @"Accept"];
        [manager.requestSerializer setValue:@"DDSqpO2YdRmshz4jCexFtUaR8dmAp1QDGP8jsnD0V9SZ4tEwoy" forHTTPHeaderField:@"X-Mashape-Key"];
    });
    return manager;
}
/*
 reader is also build on top of the base manager ::
 but the response will be parsed in a custom manner by the rureader serilizer. This serilization is done custom
 */
+(AFHTTPSessionManager *)readerSessionManager
{
    static AFHTTPSessionManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sessionManager = [self baseManager];
                      sessionManager.responseSerializer = [RUReaderResponseSerializer compoundResponseSerializer];
                  });
    return sessionManager;
}

@end
