//
//  RUNewsData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUNewsData.h"
#import <AFNetworking.h>

@interface RUNewsData ()
@property dispatch_group_t newsGroup;
@property NSDictionary *news;
@property (nonatomic) AFHTTPSessionManager *sessionManager;
@end

@implementation RUNewsData

+(RUNewsData *)sharedData{
    static RUNewsData *newsData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newsData = [[RUNewsData alloc] init];
    });
    return newsData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://rumobile.rutgers.edu/1/"]];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        self.newsGroup = group;
        [self requestNews];
    }
    return self;
}

-(void)requestNews{
    [self.sessionManager GET:@"news.txt" parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.news = responseObject;
            dispatch_group_leave(self.newsGroup);
        } else {
            [self requestNews];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestNews];
    }];
}

-(void)getNewsWithCompletion:(void (^)(NSDictionary *response))completionBlock{
    dispatch_group_notify(self.newsGroup, dispatch_get_main_queue(), ^{
        completionBlock([self.news copy]);
    });
}
@end
