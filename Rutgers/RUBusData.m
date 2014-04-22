//
//  RUBusData.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusData.h"
#import <AFNetworking.h>
#import "AFTBXMLResponseSerializer.h"
#import "TBXML.h"
#import "RUBusRoute.h"
#import "RUBusStop.h"

const NSString *newBrunswickAgency = @"rutgers";
const NSString *newarkAgency = @"rutgers-newark";
/*
const NSString *baseURL = @"http://webservices.nextbus.com/service/publicXMLFeed?";
const NSString *routeConfig = @"routeConfig";

const NSString *route = @"route";
const NSString *stop = @"stop";*/

@interface RUBusData ()
@property (nonatomic) AFHTTPSessionManager *sessionManager;
@property (nonatomic) NSMutableDictionary *stops;
@property (nonatomic) NSMutableDictionary *routes;
@end

@implementation RUBusData
-(id)init{
    self = [super init];
    if (self) {
        self.stops = [NSMutableDictionary dictionary];
        self.routes = [NSMutableDictionary dictionary];
        
        self.sessionManager = [AFHTTPSessionManager manager];
       
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    }
    return self;
}
-(void)getAgencyConfigWithCompletion:(void (^)(void))completionBlock{
    dispatch_group_t groupOne = dispatch_group_create();
    
    
    dispatch_group_enter(groupOne);
    [self.sessionManager GET:@"https://rumobile.rutgers.edu/1/rutgersrouteconfig.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseRouteConfig:responseObject forAgency:newBrunswickAgency];
            dispatch_group_leave(groupOne);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    
    dispatch_group_enter(groupOne);
    [self.sessionManager GET:@"https://rumobile.rutgers.edu/1/rutgers-newarkrouteconfig.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseRouteConfig:responseObject forAgency:newarkAgency];
            dispatch_group_leave(groupOne);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    
    dispatch_group_notify(groupOne, dispatch_get_main_queue(), ^{
        dispatch_group_t groupTwo = dispatch_group_create();

        
        dispatch_group_enter(groupTwo);
        [self.sessionManager GET:@"https://rumobile.rutgers.edu/1/nbactivestops.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self parseActiveStops:responseObject forAgency:newBrunswickAgency];
                dispatch_group_leave(groupTwo);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];

    
        dispatch_group_enter(groupTwo);
        [self.sessionManager GET:@"https://rumobile.rutgers.edu/1/nwkactivestops.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self parseActiveStops:responseObject forAgency:newarkAgency];
                dispatch_group_leave(groupTwo);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        dispatch_group_notify(groupTwo, dispatch_get_main_queue(), completionBlock);
        
    });

}

-(void)parseRouteConfig:(NSDictionary *)routeConfig forAgency:(NSString *)agency{
    
    NSMutableDictionary *routesByTag = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTitle = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTag = [NSMutableDictionary dictionary];

    NSDictionary *routes = routeConfig[@"routes"];
    for (NSString *routeTag in routes) {
        routesByTag[routeTag] = [[RUBusRoute alloc] initWithDictionary:routes[routeTag]];
    }
    
    NSDictionary *stops = routeConfig[@"stops"];
    for (NSString *stopTag in stops) {
        RUBusStop *stop = [[RUBusStop alloc] initWithDictionary:stops[stopTag]];
        stop.tag = stopTag;
        stopsByTag[stopTag] = stop;
        
        NSMutableArray *stopsForTitle = stopsByTitle[stop.title];
        if (!stopsForTitle) {
            stopsForTitle = [NSMutableArray array];
            stopsByTitle[stop.title] = stopsForTitle;
        }
        [stopsForTitle addObject:stop];
    }
    
    for (NSString *routeTag in routesByTag) {
        RUBusRoute *route = routesByTag[routeTag];
        route.tag = routeTag;
        NSArray *stopTags = route.stops;
        NSMutableArray *stops = [NSMutableArray array];
        for (NSString *stopTag in stopTags) {
            [stops addObject:stopsByTag[stopTag]];
        }
        route.stops = stops;
        
    }

    self.stops[agency] = stopsByTitle;
    self.routes[agency] = routesByTag;
}

-(void)parseActiveStops:(NSDictionary *)routeConfig forAgency:(NSString *)agency{
    NSArray *routes = routeConfig[@"routes"];
    for (NSDictionary *routeDescription in routes) {
        RUBusRoute *route = self.routes[agency][routeDescription[@"tag"]];
        route.active = YES;
    }
    
    NSArray *stops = routeConfig[@"stops"];
    for (NSDictionary *stopDescription in stops) {
        NSArray *stops = self.stops[agency][stopDescription[@"title"]];
        
        for (RUBusStop *stop in stops) {
            stop.active = YES;
        }
    }

}
@end
