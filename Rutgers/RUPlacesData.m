//
//  RUPlacesData.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesData.h"
#import <AFNetworking.h>

@interface RUPlacesData ()
@property (nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation RUPlacesData
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",nil];
    }
    return self;
}
-(void)getPlacesWithCompletion:(void (^)(void))completionBlock{
    [self.sessionManager GET:@"https://rumobile.rutgers.edu/1/places.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *places = [responseObject[@"all"] allValues];
            self.places = places;
            completionBlock();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock{
    NSArray *results = [self.places filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@",query]];
    completionBlock(results);
}
@end
