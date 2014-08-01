//
//  RUBusDataLoadingManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusDataLoadingManager.h"
#import "RUBusDataAgencyManager.h"
#import "RUBusStop.h"
#import "RUBusRoute.h"
#import "NSArray+RUBusStop.h"
#import "RUNetworkManager.h"
#import "RUBusData.h"


@interface RUBusDataLoadingManager ()
@property NSDictionary *agencyManagers;
@end

@implementation RUBusDataLoadingManager
+(instancetype)sharedInstance{
    static RUBusDataLoadingManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RUBusDataLoadingManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.agencyManagers = @{
                                newBrunswickAgency : [RUBusDataAgencyManager managerForAgency:newBrunswickAgency],
                                newarkAgency : [RUBusDataAgencyManager managerForAgency:newarkAgency]
                                };
    }
    return self;
}


-(void)fetchAllStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler{
    RUBusDataAgencyManager *agencyManager = self.agencyManagers[agency];
    [agencyManager fetchAllStopsWithCompletion:handler];
}

-(void)fetchAllRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler{
    RUBusDataAgencyManager *agencyManager = self.agencyManagers[agency];
    [agencyManager fetchAllRoutesWithCompletion:handler];
}

-(void)fetchActiveStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler{
    RUBusDataAgencyManager *agencyManager = self.agencyManagers[agency];
    [agencyManager fetchActiveStopsWithCompletion:handler];
}

-(void)fetchActiveRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler{
    RUBusDataAgencyManager *agencyManager = self.agencyManagers[agency];
    [agencyManager fetchActiveRoutesWithCompletion:handler];
}

-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void (^)(NSArray *stops, NSError *error))handler{
    dispatch_group_t group = dispatch_group_create();

    NSMutableArray *allStops = [NSMutableArray array];
    __block NSError *outerError;
    
    [self.agencyManagers enumerateKeysAndObjectsUsingBlock:^(NSString *const agency, RUBusDataAgencyManager *agencyManager, BOOL *stop) {
        dispatch_group_enter(group);
        [agencyManager fetchActiveStopsNearbyLocation:location completion:^(NSArray *stops, NSError *error) {
            [allStops addObjectsFromArray:stops];
            dispatch_group_leave(group);
            if (error) outerError = error;
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        handler(allStops,outerError);
    });
}


#pragma mark - predictions api
-(void)getPredictionsForItem:(id)item withSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock{
    if (!([item isKindOfClass:[RUBusRoute class]] || ([item isKindOfClass:[NSArray class]] && [item isArrayOfBusStops]))) return;
    
    [[RUNetworkManager xmlSessionManager] GET:[self urlStringForItem:item] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id predictions = responseObject[@"predictions"];
            successBlock(predictions);
        } else {
            failureBlock();
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureBlock();
    }];
}

-(NSString *)urlStringForItem:(id)item{
    NSString *agency = [item agency];
    return [self.agencyManagers[agency] urlStringForItem:item];
}


#pragma mark - search
-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *results))handler{
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *allResults = [NSMutableArray array];
    
    [self.agencyManagers enumerateKeysAndObjectsUsingBlock:^(NSString *const agency, RUBusDataAgencyManager *agencyManager, BOOL *stop) {
        dispatch_group_enter(group);
        [agencyManager queryStopsAndRoutesWithString:query completion:^(NSArray *results) {
            [allResults addObjectsFromArray:results];
            dispatch_group_leave(group);
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSArray *sortedResults = [self sortSearchResults:allResults forQuery:query];
        handler(sortedResults);
    });
}

-(NSArray *)sortSearchResults:(NSArray *)results forQuery:(NSString *)query{
    NSPredicate *beginsWithPredicate = [NSPredicate predicateWithFormat:@"title beginswith[cd] %@",query];
    return [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        BOOL oneBeginsWithString;
        if ([obj1 isKindOfClass:[RUBusRoute class]]) {
            oneBeginsWithString = [beginsWithPredicate evaluateWithObject:obj1];
        } else {
            RUBusStop *stop = [obj1 firstObject];
            oneBeginsWithString = [beginsWithPredicate evaluateWithObject:stop];
        }
        
        BOOL twoBeginsWithString;
        if ([obj2 isKindOfClass:[RUBusRoute class]]) {
            twoBeginsWithString = [beginsWithPredicate evaluateWithObject:obj2];
        } else {
            RUBusStop *stop = [obj2 firstObject];
            twoBeginsWithString = [beginsWithPredicate evaluateWithObject:stop];
        }
        
        if (oneBeginsWithString && !twoBeginsWithString) {
            return NSOrderedAscending;
        } else if (!oneBeginsWithString && twoBeginsWithString) {
            return NSOrderedDescending;
        }
        
        if ([obj1 active] && ![obj2 active]) {
            return NSOrderedAscending;
        } else if (![obj1 active] && [obj2 active]) {
            return NSOrderedDescending;
        }
        
        NSString *titleOne = [obj1 title];
        NSString *titleTwo = [obj2 title];
        return [titleOne compare:titleTwo options:NSNumericSearch|NSCaseInsensitiveSearch];
    }];
}


@end
