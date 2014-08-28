//
//  RUBusDataAgencyManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusDataAgencyManager.h"
#import "RUBusDataLoadingManager.h"
#import "RULocationManager.h"
#import "RUBusRoute.h"
#import "RUBusStop.h"
#import "RUMultiStop.h"
#import "NSArray+Sort.h"
#import "NSPredicate+SearchPredicate.h"


#define URLS @{newBrunswickAgency: @"rutgersrouteconfig.txt", newarkAgency: @"rutgers-newarkrouteconfig.txt"}
#define ACTIVE_URLS @{newBrunswickAgency: @"nbactivestops.txt", newarkAgency: @"nwkactivestops.txt"}

@interface RUBusDataAgencyManager ()
@property NSString *agency;

@property NSDictionary *stops;
@property NSDictionary *routes;

@property NSArray *activeStops;
@property NSArray *activeRoutes;

@property dispatch_group_t agencyGroup;
@property dispatch_group_t activeGroup;

@property NSDate *lastTaskDate;
@end

@implementation RUBusDataAgencyManager
-(instancetype)initWithAgency:(NSString *)agency{
    self = [super init];
    if (self) {
        self.agency = agency;

        self.agencyGroup = dispatch_group_create();
        self.activeGroup = dispatch_group_create();
        
        [self getAgencyConfig];
    }
    return self;
}

+(instancetype)managerForAgency:(NSString *)agency{
    return [[self alloc] initWithAgency:agency];
}

-(BOOL)activeStopsAndRoutesNeedsRefresh{
    return (!self.lastTaskDate || [[NSDate date] timeIntervalSinceDate:self.lastTaskDate] > 45);
}

-(void)performBlockWhenAgencyLoaded:(dispatch_block_t)block{
    dispatch_group_notify(self.agencyGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

-(void)performBlockWhenActiveLoaded:(dispatch_block_t)block{
    if ([self activeStopsAndRoutesNeedsRefresh]) [self getActiveStopsAndRoutes];
    dispatch_group_notify(self.agencyGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_notify(self.activeGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
    });
}

-(void)fetchAllStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler{
    [self performBlockWhenActiveLoaded:^{
        handler([[self.stops allValues] sortByKeyPath:@"title"],nil);
    }];
}

-(void)fetchAllRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler{
    [self performBlockWhenActiveLoaded:^{
        handler([[self.routes allValues] sortByKeyPath:@"title"],nil);
    }];
}

-(void)fetchActiveStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler{
    [self performBlockWhenActiveLoaded:^{
        handler(self.activeStops,nil);
    }];
}

-(void)fetchActiveRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler{
    [self performBlockWhenActiveLoaded:^{
        handler(self.activeRoutes,nil);
    }];
}

#pragma mark - nearby api
-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void(^)(NSArray *stops, NSError *error))handler{
    if (!location) {
        handler(@[],nil);
        return;
    }
    
    [self performBlockWhenActiveLoaded:^{
        NSMutableArray *nearbyStops = [NSMutableArray array];
        
        [self.stops enumerateKeysAndObjectsUsingBlock:^(id key, RUMultiStop *stop, BOOL *end) {
            if ([stop active]) {
                CLLocationDistance distance = [self distanceOfStop:stop fromLocation:location];
                if (distance < NEARBY_DISTANCE) [nearbyStops addObject:stop];
            }
        }];
        
        NSArray *sortedNearbyStops = [nearbyStops sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CLLocationDistance distanceOne = [self distanceOfStop:obj1 fromLocation:location];
            CLLocationDistance distanceTwo = [self distanceOfStop:obj2 fromLocation:location];
            
            if (distanceOne < distanceTwo) return NSOrderedAscending;
            else if (distanceOne > distanceTwo) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        handler(sortedNearbyStops,nil);
    }];
}

-(CLLocationDistance)distanceOfStop:(RUMultiStop *)multiStop fromLocation:(CLLocation *)location{
    CLLocationDistance minDistance = -1;
    for (RUBusStop *stop in multiStop.stops) {
        CLLocationDistance distance = [stop.location distanceFromLocation:location];
        if (minDistance == -1 || distance < minDistance) {
            minDistance = distance;
        }
    }
    return minDistance;
}

#pragma mark - searching

-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *routes, NSArray *stops))handler{
    [self performBlockWhenAgencyLoaded:^{
        NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"title"];
        
        NSArray *routes = [self.routes.allValues filteredArrayUsingPredicate:predicate];
        NSArray *stops = [self.stops.allValues filteredArrayUsingPredicate:predicate];
        
        handler(routes,stops);
    }];
}

#pragma mark - api requests

-(void)getAgencyConfig{
    dispatch_group_enter(self.agencyGroup);
    [[RUNetworkManager sessionManager] GET:URLS[self.agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
       
        [self parseRouteConfig:responseObject];
        dispatch_group_leave(self.agencyGroup);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getAgencyConfig];
            dispatch_group_leave(self.agencyGroup);
        });
        
    }];
}

-(void)getActiveStopsAndRoutes{
    dispatch_group_enter(self.activeGroup);
    self.lastTaskDate = [NSDate date];
    [[RUNetworkManager sessionManager] GET:ACTIVE_URLS[self.agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
      
        [self performBlockWhenAgencyLoaded:^{
            [self parseActiveStopsAndRoutes:responseObject];
            dispatch_group_leave(self.activeGroup);
        }];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getActiveStopsAndRoutes];
            dispatch_group_leave(self.activeGroup);
        });

    }];
}

#pragma mark - predictions for multi stops
static NSString *const format = @"&stops=%@|null|%@";

-(NSString *)urlStringForItem:(id)item{
    if ([item isKindOfClass:[RUMultiStop class]]) {
        RUMultiStop *stop = item;
        NSArray *stops = stop.stops;
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?a=%@&command=predictionsForMultiStops",self.agency];
        
        //revise this
        NSMutableArray *descriptors = [NSMutableArray array];
        
        for (RUBusStop *stop in stops){
            for (RUBusRoute *route in stop.activeRoutes) {
                [descriptors addObject:@[route.tag,stop.tag]];
            }
        }
        
        NSArray *sortedDescriptors = [descriptors sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *routeTagOne = [obj1 firstObject];
            NSString *routeTagTwo = [obj2 firstObject];
            return [[self.routes[routeTagOne] title] localizedCaseInsensitiveCompare:[self.routes[routeTagTwo] title]];
        }];
        
        for (NSArray *descriptor in sortedDescriptors) {
            [urlString appendFormat:format, [descriptor firstObject], [descriptor lastObject]];
        }
        
        return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else if ([item isKindOfClass:[RUBusRoute class]]){
        RUBusRoute *route = item;
        
        NSString *agency = route.agency;
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?a=%@&command=predictionsForMultiStops",agency];
        
        for (RUBusStop *stop in route.stops){
            [urlString appendFormat:format,route.tag,stop.tag];
        }
        return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}


#pragma mark - api response parsing
-(void)parseRouteConfig:(NSDictionary *)routeConfig{
    
    NSMutableDictionary *routesByTag = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTitle = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTag = [NSMutableDictionary dictionary];
    
    //pulls routes out of response json
    NSDictionary *routes = routeConfig[@"routes"];
    for (NSString *routeTag in routes) {
        //allocs a route with its json representation
        RUBusRoute *route = [[RUBusRoute alloc] initWithDictionary:routes[routeTag]];
        route.agency = self.agency;
        route.tag = routeTag;
        routesByTag[routeTag] = route;
    }
    
    //pulls stops out of response json
    NSDictionary *stops = routeConfig[@"stops"];
    for (NSString *stopTag in stops) {
        //allocs a stop with its json representation
        RUBusStop *stop = [[RUBusStop alloc] initWithDictionary:stops[stopTag]];
        stop.agency = self.agency;
        stop.tag = stopTag;
        stopsByTag[stopTag] = stop;
        
        //checks if the title has been seen yet
        RUMultiStop *stopsForTitle = stopsByTitle[stop.title];
        if (!stopsForTitle) {
            //if not make an array to hold stops with this title
            stopsForTitle = [[RUMultiStop alloc] init];
            stopsByTitle[stop.title] = stopsForTitle;
        }
        //add the stop to the array of stops with identical titles
        [stopsForTitle addStopsObject:stop];
    }
    
    //looping over the route objects we have just made
    for (NSString *routeTag in routesByTag) {
        RUBusRoute *route = routesByTag[routeTag];
        //retrieve the temp array of stop tags
        NSArray *stopTags = route.stops;
        //and use it to get an array of the actual stop objects we have made
        NSMutableArray *stops = [NSMutableArray array];
        for (NSString *stopTag in stopTags) {
            RUBusStop *stop = stopsByTag[stopTag];
            [stops addObject:stop];
            stop.routes = [stop.routes arrayByAddingObject:route];
        }
        route.stops = stops;
    }
    
    self.stops = stopsByTitle;
    self.routes = routesByTag;
}

-(void)parseActiveStopsAndRoutes:(NSDictionary *)activeConfig{
    NSSet *activeRouteTags = [NSSet setWithArray:[activeConfig[@"routes"] valueForKey:@"tag"]];
    NSMutableArray *activeRoutes = [NSMutableArray array];
    
    for (RUBusRoute *route in self.routes.allValues) {
        BOOL active = [activeRouteTags containsObject:route.tag];
        route.active = active;
        if (active) {
            [activeRoutes addObject:route];
        }
    }
    
    NSSet *activeStopTitles = [NSSet setWithArray:[activeConfig[@"stops"] valueForKey:@"title"]];
    NSMutableArray *activeStops = [NSMutableArray array];

    for (RUMultiStop *stop in self.stops.allValues) {
        BOOL active = [activeStopTitles containsObject:stop.title];
        stop.active = active;
        if (active) {
            [activeStops addObject:stop];
        }
    }
    
    self.activeRoutes = [activeRoutes sortByKeyPath:@"title"];

    self.activeStops = [activeStops sortByKeyPath:@"title"];
}

@end
