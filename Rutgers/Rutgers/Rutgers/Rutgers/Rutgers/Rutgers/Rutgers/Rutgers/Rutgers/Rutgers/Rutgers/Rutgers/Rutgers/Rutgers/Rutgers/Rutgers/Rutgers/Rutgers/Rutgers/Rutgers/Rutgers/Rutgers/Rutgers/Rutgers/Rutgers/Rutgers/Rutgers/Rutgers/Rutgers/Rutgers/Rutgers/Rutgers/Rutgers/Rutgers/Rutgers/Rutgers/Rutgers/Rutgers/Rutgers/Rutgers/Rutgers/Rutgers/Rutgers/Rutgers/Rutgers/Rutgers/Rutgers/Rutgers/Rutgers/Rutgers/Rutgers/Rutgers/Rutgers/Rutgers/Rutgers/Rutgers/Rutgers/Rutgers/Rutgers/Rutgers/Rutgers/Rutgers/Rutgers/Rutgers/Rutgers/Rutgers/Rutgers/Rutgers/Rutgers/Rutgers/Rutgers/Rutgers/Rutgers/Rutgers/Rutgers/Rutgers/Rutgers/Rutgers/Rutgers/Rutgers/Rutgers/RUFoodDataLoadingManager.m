//
//  RUFoodDataManager.m
//  Rutgers
//
//  Created by Open Systems Solutions on 2/26/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUFoodDataLoadingManager.h"
#import "RUNetworkManager.h"
#import "RUDataLoadingManager_Private.h"
#import "DataTuple.h"
#import "NSDictionary+DiningHall.h"
#import "NSURL+RUAdditions.h"

@interface RUFoodDataLoadingManager ()
@property (nonatomic) NSArray *diningHalls;
@end

@implementation RUFoodDataLoadingManager

+(RUFoodDataLoadingManager *)sharedInstance{
    static RUFoodDataLoadingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RUFoodDataLoadingManager alloc] init];
    });
    return sharedInstance;
}

-(void)load {
    [self willBeginLoad];
    [[RUNetworkManager sessionManager] GET:@"rutgers-dining.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.diningHalls = [self parseResponse:responseObject];
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didEndLoad:NO withError:error];
    }];
}

-(void)getDiningHallsWithCompletion:(void (^)(NSArray <DataTuple *> *, NSError *))completionBlock{
    [self performWhenLoaded:^(NSError *error) {
        completionBlock(self.diningHalls, error);
    }];
}

-(void)getSerializedDiningHall:(NSString *)serializedDiningHall withCompletion:(void (^)(DataTuple *, NSError *))completionBlock{
    [self performWhenLoaded:^(NSError *error) {
        DataTuple *matchingDiningHall;
        for (DataTuple *diningHall in self.diningHalls) {
            if ([[[[diningHall.object diningHallShortName] lowercaseString] rutgersStringEscape] isEqualToString:serializedDiningHall]) {
                matchingDiningHall = diningHall;
                break;
            }
        }
        
        completionBlock(matchingDiningHall, error);
    }];
}

-(NSArray *)parseResponse:(NSArray *)response{
    NSMutableArray *parsedDiningHalls = [NSMutableArray array];
    for (NSDictionary *diningHall in response) {
        DataTuple *parsedDiningHall = [[DataTuple alloc] initWithTitle:diningHall[@"location_name"] object:diningHall];
        [parsedDiningHalls addObject:parsedDiningHall];
    }
    return parsedDiningHalls;
}

@end