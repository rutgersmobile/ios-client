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
+(RUPlacesData *)sharedInstance{
    static RUPlacesData *placesData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placesData = [[RUPlacesData alloc] init];
    });
    return placesData;
}
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
            self.placesLoaded = YES;
            completionBlock();
        } else {
            [self getPlacesWithCompletion:completionBlock];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self getPlacesWithCompletion:completionBlock];
    }];
}
-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock{
    NSArray *results = [self.places filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@",query]];
    
    NSPredicate *beginsWithPredicate = [NSPredicate predicateWithFormat:@"title beginswith[cd] %@",query];
    results = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        BOOL one = [beginsWithPredicate evaluateWithObject:obj1];
        BOOL two = [beginsWithPredicate evaluateWithObject:obj2];
        if (one && !two) {
            return NSOrderedAscending;
        } else if (!one && two) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    completionBlock(results);
}
@end
