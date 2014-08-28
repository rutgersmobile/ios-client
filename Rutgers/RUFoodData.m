//
//  RUFoodData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodData.h"
#import <AFNetworking.h>

@interface RUFoodData ()
@end

@implementation RUFoodData

+(void)getFoodWithSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock{
    NSString *url = @"https://rumobile.rutgers.edu/1/rutgers-dining.txt";
   // NSString *url = @"http://vps.rsopher.com/nutrition.json";
    [[RUNetworkManager sessionManager] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            successBlock(responseObject);
        } else {
            failureBlock();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureBlock();
    }];
}

@end
