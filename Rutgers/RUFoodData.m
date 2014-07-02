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
+(RUFoodData *)sharedInstance{
    static RUFoodData *foodData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        foodData = [[RUFoodData alloc] init];
    });
    return foodData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.staticDiningHalls = @[@{@"title" : @"Gateway Cafe",
                                  @"header" : @"Camden",
                                  @"data" : @"The Camden Dining Hall, the Gateway Cafe, is located at the Camden Campus Center.\n\nIt offers a variety of eateries in one convenient location.",
                                  @"view" : @"text"
                                  },
                                @{@"title" : @"Stonsby Commons & Eatery",
                                  @"header" : @"Newark",
                                  @"data" : @"Students enjoy all-you-care-to-eat dining in a contemporary setting. This exciting location offers fresh made menu items, cutting-edge American entrees, ethnically-inspired foods, vegetarian selections and lots more... \n\nThe Commons also features upscale Premium entrees and fresh baked goods from our in house bakery or local vendors.",
                                  @"view" : @"text"
                                  }
                                ];
    }
    return self;
}

-(void)getFoodWithSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock{
    NSString *url = @"https://rumobile.rutgers.edu/1/rutgers-dining.txt";
   // NSString *url = @"http://vps.rsopher.com/nutrition.json";
    [[RUNetworkManager jsonSessionManager] GET:url parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *food = [responseObject filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                for (NSDictionary *meal in evaluatedObject[@"meals"]) {
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
