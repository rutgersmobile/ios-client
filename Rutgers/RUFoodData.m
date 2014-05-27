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
@property dispatch_group_t foodGroup;
@property NSArray *food;
@property (nonatomic) AFHTTPSessionManager *sessionManager;
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
        self.sessionManager = [[AFHTTPSessionManager alloc] init];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",nil];
      
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
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        self.foodGroup = group;
        [self requestFood];
    }
    return self;
}
//

-(void)requestFood{
   // NSString *url = @"https://rumobile.rutgers.edu/1/rutgers-dining.txt";
    NSString *url = @"http://vps.rsopher.com/nutrition.json";
    [self.sessionManager GET:url parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.food = [responseObject filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                for (NSDictionary *meal in evaluatedObject[@"meals"]) {
                    if ([meal[@"genres"] count] > 0) {
                        return true;
                    }
                }
                return false;
            }]];
            dispatch_group_leave(self.foodGroup);
        } else {
            [self requestFood];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFood];
    }];
}

-(void)getFoodWithCompletion:(void (^)(NSArray *response))completionBlock{
   
    dispatch_group_notify(self.foodGroup, dispatch_get_main_queue(), ^{
        completionBlock([self.food copy]);
    });
}

@end
