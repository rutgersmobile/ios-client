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
#import "RUMultiStop.h"

NSString * const newBrunswickAgency = @"rutgers";
NSString * const newarkAgency = @"rutgers-newark";

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

+(NSString *)titleForAgency:(NSString *)agency{
    return @{newBrunswickAgency : @"New Brunswick", newarkAgency : @"Newark"}[agency];
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
    [self.agencyManagers[agency] fetchAllStopsWithCompletion:handler];
}

-(void)fetchAllRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler{
    [self.agencyManagers[agency] fetchAllRoutesWithCompletion:handler];
}

-(void)fetchActiveStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler{
    [self.agencyManagers[agency] fetchActiveStopsWithCompletion:handler];
}

-(void)fetchActiveRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler{
    [self.agencyManagers[agency] fetchActiveRoutesWithCompletion:handler];
}

-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void (^)(NSArray *stops, NSError *error))handler{
    dispatch_group_t group = dispatch_group_create();

    NSMutableArray *allStops = [NSMutableArray array];
    __block NSError *outerError;
    
    [self.agencyManagers enumerateKeysAndObjectsUsingBlock:^(NSString *const agency, RUBusDataAgencyManager *agencyManager, BOOL *stop) {
        dispatch_group_enter(group);
        [agencyManager fetchActiveStopsNearbyLocation:location completion:^(NSArray *stops, NSError *error) {
            [allStops addObjectsFromArray:stops];
            if (error) outerError = error;
            dispatch_group_leave(group);
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        handler(allStops,outerError);
    });
}


#pragma mark - predictions api
-(void)getPredictionsForItem:(id)item completion:(void (^)(NSArray *, NSError *))handler{
    [[RUNetworkManager sessionManager] GET:[self urlStringForItem:item] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id predictions = responseObject[@"predictions"];
            handler(predictions,nil);
        } else {
            handler(nil,nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        handler(nil,error);
    }];
}

-(NSString *)urlStringForItem:(id)item{
    NSString *agency = [item agency];
    return [self.agencyManagers[agency] urlStringForItem:item];
}

#pragma mark - search
-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *routes, NSArray *stops, NSError *error))handler{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_group_t group = dispatch_group_create();
        
        NSMutableArray *allRoutes = [NSMutableArray array];
        NSMutableArray *allStops = [NSMutableArray array];
        
        __block NSError *outerError;
        
        [self.agencyManagers enumerateKeysAndObjectsUsingBlock:^(NSString *const agency, RUBusDataAgencyManager *agencyManager, BOOL *stop) {
            dispatch_group_enter(group);
            [agencyManager queryStopsAndRoutesWithString:query completion:^(NSArray *routes, NSArray *stops, NSError *error) {
                if (error) outerError = error;
                [allRoutes addObjectsFromArray:routes];
                [allStops addObjectsFromArray:stops];
                dispatch_group_leave(group);
            }];
        }];
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray *sortedRoutes = [self sortSearchResults:allRoutes forQuery:query];
            NSArray *sortedStops = [self sortSearchResults:allStops forQuery:query];
            handler(sortedRoutes,sortedStops,outerError);
        });
    });
}

-(NSArray *)sortSearchResults:(NSArray *)results forQuery:(NSString *)query{
    return [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if ([obj1 active] && ![obj2 active]) {
            return NSOrderedAscending;
        } else if (![obj1 active] && [obj2 active]) {
            return NSOrderedDescending;
        }

        return [[obj1 title] compare:[obj2 title] options:NSNumericSearch|NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];
}


@end
