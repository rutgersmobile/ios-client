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

@property BOOL agencyLoading;
@property BOOL agencyFinishedLoading;
@property NSError *agencyLoadingError;

@property BOOL activeLoading;
@property BOOL activeFinishedLoading;
@property NSError *activeLoadingError;
@property NSDate *lastActiveTaskDate;

@property NSDictionary *stops;
@property NSDictionary *routes;

@property NSArray *activeStops;
@property NSArray *activeRoutes;

@property dispatch_group_t agencyGroup;
@property dispatch_group_t activeGroup;

@end

@implementation RUBusDataAgencyManager
-(instancetype)initWithAgency:(NSString *)agency{
    self = [super init];
    if (self) {
        self.agency = agency;

        self.agencyGroup = dispatch_group_create();
        self.activeGroup = dispatch_group_create();
    }
    return self;
}

+(instancetype)managerForAgency:(NSString *)agency{
    return [[self alloc] initWithAgency:agency];
}

-(BOOL)agencyConfigNeedsLoad{
    return !(self.agencyLoading || self.agencyFinishedLoading);
}

-(void)performWhenAgencyLoaded:(void(^)(NSError *error))handler{
    if ([self agencyConfigNeedsLoad]) {
        [self loadAgencyConfig];
    }
    dispatch_group_notify(self.agencyGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        handler(self.agencyLoadingError);
    });
}

-(BOOL)activeStopsAndRoutesNeedLoad{
    return (!(self.activeLoading || self.activeFinishedLoading) || [[NSDate date] timeIntervalSinceDate:self.lastActiveTaskDate] > 45);
}

-(void)performWhenActiveLoaded:(void(^)(NSError *error))handler{
    [self performWhenAgencyLoaded:^(NSError *error) {
        if (error) {
            handler(error);
        } else {
            if ([self activeStopsAndRoutesNeedLoad]) {
                [self loadActiveStopsAndRoutes];
            }
            dispatch_group_notify(self.activeGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                handler(self.activeLoadingError);
            });
        }
    }];
}

-(void)fetchAllStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler{
    [self performWhenActiveLoaded:^(NSError *error) {
        handler([[self.stops allValues] sortByKeyPath:@"title"], error);
    }];
}

-(void)fetchAllRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler{
    [self performWhenActiveLoaded:^(NSError *error) {
        handler([[self.routes allValues] sortByKeyPath:@"title"], error);
    }];
}

-(void)fetchActiveStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler{
    [self performWhenActiveLoaded:^(NSError *error) {
        handler(self.activeStops, error);
    }];
}

-(void)fetchActiveRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler{
    [self performWhenActiveLoaded:^(NSError *error) {
        handler(self.activeRoutes, error);
    }];
}

#pragma mark - nearby api
-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void(^)(NSArray *stops, NSError *error))handler{
    if (!location) {
        handler(@[],nil);
        return;
    }
    
    [self performWhenActiveLoaded:^(NSError *error) {
        
        NSArray *sortedNearbyStops = [[self.stops.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RUMultiStop *stop, NSDictionary *bindings) {
            return (stop.active && [self distanceOfStop:stop fromLocation:location] < NEARBY_DISTANCE);
        }]] sortedArrayUsingComparator:^NSComparisonResult(RUMultiStop *stopOne, RUMultiStop *stopTwo) {
            CLLocationDistance distanceOne = [self distanceOfStop:stopOne fromLocation:location];
            CLLocationDistance distanceTwo = [self distanceOfStop:stopTwo fromLocation:location];
            
            if (distanceOne < distanceTwo) return NSOrderedAscending;
            else if (distanceOne > distanceTwo) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        handler(sortedNearbyStops, error);

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

-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *routes, NSArray *stops, NSError *error))handler{
    
    [self performWhenAgencyLoaded:^(NSError *error) {
        NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"title"];

        NSArray *routes = [self.routes.allValues filteredArrayUsingPredicate:predicate];
        NSArray *stops = [self.stops.allValues filteredArrayUsingPredicate:predicate];
        
        handler(routes,stops,error);
    }];
}

#pragma mark - api requests

-(void)loadAgencyConfig{
    dispatch_group_enter(self.agencyGroup);
    
    self.agencyLoading = YES;
    self.agencyFinishedLoading = NO;
    self.agencyLoadingError = nil;
    
    [[RUNetworkManager sessionManager] GET:URLS[self.agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self parseRouteConfig:responseObject];
        
        self.agencyLoading = NO;
        self.agencyFinishedLoading = YES;
        self.agencyLoadingError = nil;
        
        dispatch_group_leave(self.agencyGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        self.agencyLoading = NO;
        self.agencyFinishedLoading = NO;
        self.agencyLoadingError = error;
        
        dispatch_group_leave(self.agencyGroup);
    }];
}

-(void)loadActiveStopsAndRoutes{
    dispatch_group_enter(self.activeGroup);
    
    self.activeLoading = YES;
    self.activeFinishedLoading = NO;
    self.activeLoadingError = nil;
    
    [[RUNetworkManager sessionManager] GET:ACTIVE_URLS[self.agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self parseActiveStopsAndRoutes:responseObject];
        
        self.activeLoading = NO;
        self.activeFinishedLoading = YES;
        self.activeLoadingError = nil;
        self.lastActiveTaskDate = [NSDate date];
        
        dispatch_group_leave(self.activeGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        self.activeLoading = NO;
        self.activeFinishedLoading = NO;
        self.activeLoadingError = error;
        
        dispatch_group_leave(self.activeGroup);
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
