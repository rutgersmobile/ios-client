//
//  RUNetworkManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface RUNetworkManager : NSObject
+(AFHTTPSessionManager *)jsonSessionManager;
+(AFHTTPSessionManager *)xmlSessionManager;
+(AFHTTPSessionManager *)HTTPSessionManager;
@end