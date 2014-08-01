//
//  RUFoodData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFoodData.h"
#import <AFNetworking.h>
#import "RUNetworkManager.h"

@interface RUFoodData ()
@end

@implementation RUFoodData

+(void)getFoodWithSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock{
    NSString *url = @"https://rumobile.rutgers.edu/1/rutgers-dining.txt";
   // NSString *url = @"http://vps.rsopher.com/nutrition.json";
    [[RUNetworkManager jsonSessionManager] GET:url parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *food = [responseObject filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *diningHall, NSDictionary *bindings) {
                for (NSDictionary *meal in diningHall[@"meals"]) {
                    if ([meal[@"genres"] count] > 0) {
                        return true;
                    }
                }
                return false;
            }]];
            successBlock(food);
        } else {
            failureBlock();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureBlock();
    }];
}

@end
