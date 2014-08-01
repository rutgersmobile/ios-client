//
//  RUBusData.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusData.h"
#import "NSArray+RUBusStop.h"
#import "RUBusRoute.h"
#import "RUBusStop.h"
#import "RULocationManager.h"
#import "RUNetworkManager.h"

NSString const *newBrunswickAgency = @"rutgers";
NSString const *newarkAgency = @"rutgers-newark";

@interface RUBusData ()

@property NSMutableDictionary *stops;
@property NSMutableDictionary *routes;
@property NSMutableDictionary *allStopsAndRoutes;

@property NSMutableDictionary *activeStops;
@property NSMutableDictionary *activeRoutes;

@property NSDate *lastActiveStopsAndRoutesUpdateDate;

@property NSMutableDictionary *agencyTasks;
@property NSMutableDictionary *activeStopsAndRoutesTasks;

@property dispatch_group_t agencyGroup;
@property dispatch_group_t activeGroup;
@end

@implementation RUBusData
+(RUBusData *)sharedInstance{
    static RUBusData *busData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        busData = [[RUBusData alloc] init];
    });
    return busData;
}

-(id)init{
    self = [super init];
    if (self) {
        self.stops = [NSMutableDictionary dictionary];
        self.routes = [NSMutableDictionary dictionary];
        self.activeStops = [NSMutableDictionary dictionary];
        self.activeRoutes = [NSMutableDictionary dictionary];
        self.allStopsAndRoutes = [NSMutableDictionary dictionary];
        
        self.agencyTasks = [NSMutableDictionary dictionary];
        self.activeStopsAndRoutesTasks = [NSMutableDictionary dictionary];
        
        self.agencyGroup = dispatch_group_create();
        self.activeGroup = dispatch_group_create();
        
        [self getBusData];
    }
    return self;
}

#pragma mark - nearby api

-(void)getActiveStopsNearLocation:(CLLocation *)location completion:(void (^)(NSArray *results))completionBlock{
    if (!location) {
        completionBlock(@[]);
        return;
    }
    dispatch_group_notify(self.activeGroup, dispatch_get_main_queue(), ^{
        for (NSString *agency in @[newBrunswickAgency,newarkAgency]) {
            NSMutableArray *nearbyStops = [NSMutableArray array];
            
            NSDictionary *stops = self.stops[agency];
            [stops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj active]) {
                    CLLocationDistance distance = [self distanceOfStops:obj fromLocation:location];
                    if (distance < NEARBY_DISTANCE) {
                        [nearbyStops addObject:obj];
                    }
                }
            }];
            
            if ([nearbyStops count]) {
                NSArray *sortedNearbyStops = [nearbyStops sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    CLLocationDistance distanceOne = [self distanceOfStops:obj1 fromLocation:location];
                    CLLocationDistance distanceTwo = [self distanceOfStops:obj2 fromLocation:location];
                    
                    if (distanceOne < distanceTwo) return NSOrderedAscending;
                    else if (distanceOne > distanceTwo) return NSOrderedDescending;
                    return NSOrderedSame;
                }];
                completionBlock(sortedNearbyStops);
                break;
            }
        }
    });
}

-(CLLocationDistance)distanceOfStops:(NSArray *)stops fromLocation:(CLLocation *)location{
    CLLocationDistance minDistance = -1;
    for (RUBusStop *stop in stops) {
        CLLocationDistance distance = [stop.location distanceFromLocation:location];
        if (minDistance == -1 || distance < minDistance) {
            minDistance = distance;
        }
    }
    return minDistance;
}

#pragma mark - network api functions
-(void)getBusData{
    dispatch_group_enter(self.activeGroup);
    [self getAgencyConfig];
    [self getActiveStopsAndRoutes];
    dispatch_group_notify(self.agencyGroup, dispatch_get_main_queue(), ^{
        dispatch_group_leave(self.activeGroup);
    });
}

-(void)getAgencyConfig{
    dispatch_group_enter(self.agencyGroup);
    [self getAgencyConfigForAgency:newBrunswickAgency];
    dispatch_group_enter(self.agencyGroup);
    [self getAgencyConfigForAgency:newarkAgency];
}

-(void)getAgencyConfigForAgency:(const NSString *)agency{
    NSDictionary *urls = @{newBrunswickAgency: @"rutgersrouteconfig.txt", newarkAgency: @"rutgers-newarkrouteconfig.txt"};
    self.agencyTasks[agency] = [[RUNetworkManager jsonSessionManager] GET:urls[agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseRouteConfig:responseObject forAgency:agency];
        }
        
        dispatch_group_leave(self.agencyGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getAgencyConfigForAgency:agency];
        });
        
    }];
}

-(void)getAgencyConfigWithCompletion:(void (^)(NSDictionary *allStops, NSDictionary *allRoutes))completionBlock{
    dispatch_group_notify(self.agencyGroup, dispatch_get_main_queue(), ^{
        NSMutableDictionary *stops = [NSMutableDictionary dictionary];
        for (NSString *agency in self.stops) {
            stops[agency] = [self sortArrayByTitle:[self.stops[agency] allValues]];
        }
        NSMutableDictionary *routes = [NSMutableDictionary dictionary];
        for (NSString *agency in self.routes) {
            routes[agency] = [self sortArrayByTitle:[self.routes[agency] allValues]];
        }
        completionBlock([stops copy],[routes copy]);
    });
}

-(void)getActiveStopsAndRoutesIfNeeded{
    if (self.activeStopsAndRoutesTasks[newarkAgency] && self.activeStopsAndRoutesTasks[newBrunswickAgency]) return;
        
    [self getActiveStopsAndRoutes];
}

-(void)getActiveStopsAndRoutes{
    dispatch_group_notify(self.agencyGroup, dispatch_get_main_queue(), ^{

        dispatch_group_enter(self.activeGroup);
        [self getActiveStopsAndRoutesForAgency:newBrunswickAgency];
        
        dispatch_group_enter(self.activeGroup);
        [self getActiveStopsAndRoutesForAgency:newarkAgency];
        
        dispatch_group_notify(self.activeGroup, dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.activeStopsAndRoutesTasks removeAllObjects];
            });
        });
        
    });
}

-(void)getActiveStopsAndRoutesWithCompletion:(void (^)(NSDictionary *activeStops, NSDictionary *activeRoutes))completionBlock{
    [self getActiveStopsAndRoutesIfNeeded];
    
    dispatch_group_notify(self.activeGroup, dispatch_get_main_queue(), ^{
        completionBlock([self.activeStops copy], [self.activeRoutes copy]);
    });
}

-(void)getActiveStopsAndRoutesForAgency:(const NSString *)agency{
    NSDictionary *urls = @{newBrunswickAgency: @"nbactivestops.txt", newarkAgency: @"nwkactivestops.txt"};
    
    [[RUNetworkManager jsonSessionManager] GET:urls[agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self parseActiveStopsAndRoutes:responseObject forAgency:agency];
        dispatch_group_leave(self.activeGroup);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getActiveStopsAndRoutesForAgency:agency];
        });
        
    }];
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

static NSString *const format = @"&stops=%@|null|%@";

-(NSString *)urlStringForItem:(id)item{
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *stops = item;
        NSString *agency = [stops agency];

        NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?a=%@&command=predictionsForMultiStops",agency];
        
        NSMutableArray *descriptors = [NSMutableArray array];
        
        for (RUBusStop *stop in stops){
            for (RUBusRoute *route in stop.activeRoutes) {
                [descriptors addObject:@[route.tag,stop.tag]];
            }
        }
        
        NSArray *sortedDescriptors = [descriptors sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *routeTagOne = [obj1 firstObject];
            NSString *routeTagTwo = [obj2 firstObject];
            return [[self.routes[agency][routeTagOne] title] caseInsensitiveCompare:[self.routes[agency][routeTagTwo] title]];
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

#pragma mark - search
-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *))completionBlock{
    dispatch_group_notify(self.activeGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSPredicate *containsPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",query];
        NSPredicate *beginsWithPredicate = [NSPredicate predicateWithFormat:@"title beginswith[cd] %@",query];
        
        NSArray *results = [[self.allStopsAndRoutes allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if ([evaluatedObject isKindOfClass:[RUBusRoute class]]) {
                return [containsPredicate evaluateWithObject:evaluatedObject];
            } else {
                return [containsPredicate evaluateWithObject:[evaluatedObject firstObject]];
            }
        }]];
        
        results = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
           
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(results);
        });
    });
}

#pragma mark - api response parsing
-(void)parseRouteConfig:(NSDictionary *)routeConfig forAgency:(const NSString *)agency{
    
    NSMutableDictionary *routesByTag = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTitle = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTag = [NSMutableDictionary dictionary];

    //pulls routes out of response json
    NSDictionary *routes = routeConfig[@"routes"];
    for (NSString *routeTag in routes) {
        //allocs a route with its json representation
        RUBusRoute *route = [[RUBusRoute alloc] initWithDictionary:routes[routeTag]];
        route.agency = [agency copy];
        route.tag = routeTag;
        routesByTag[routeTag] = route;
        self.allStopsAndRoutes[route.title] = route;
    }
    
    //pulls stops out of response json
    NSDictionary *stops = routeConfig[@"stops"];
    for (NSString *stopTag in stops) {
        //allocs a stop with its json representation
        RUBusStop *stop = [[RUBusStop alloc] initWithDictionary:stops[stopTag]];
        stop.agency = [agency copy];
        stop.tag = stopTag;
        stopsByTag[stopTag] = stop;
        
        //checks if the title has been seen yet
        NSMutableArray *stopsForTitle = stopsByTitle[stop.title];
        if (!stopsForTitle) {
            //if not make an array to hold stops with this title
            stopsForTitle = [NSMutableArray array];
            stopsByTitle[stop.title] = stopsForTitle;
            self.allStopsAndRoutes[stop.title] = stopsForTitle;
        }
        //add the stop to the array of stops with identical titles
        [stopsForTitle addObject:stop];
    }
    
    //looping over the route objects we have just made
    for (NSString *routeTag in routesByTag) {
        RUBusRoute *route = routesByTag[routeTag];
        //retrieve the temp array of stop tags
        NSArray *stopTags = route.stops;
        //and replace it with an array of the actual stop objects we have made
        NSMutableArray *stops = [NSMutableArray array];
        for (NSString *stopTag in stopTags) {
            RUBusStop *stop = stopsByTag[stopTag];
            [stops addObject:stop];
            stop.routes = [stop.routes arrayByAddingObject:route];
        }
        route.stops = stops;
    }

    self.stops[agency] = stopsByTitle;
    self.routes[agency] = routesByTag;
}

-(void)parseActiveStopsAndRoutes:(NSDictionary *)activeConfig forAgency:(const NSString *)agency{
    NSArray *activeRoutes = activeConfig[@"routes"];
    NSArray *routes = [self.routes[agency] allValues];
    
    for (RUBusRoute *route in routes) {
        route.active = NO;
    }
    
    for (NSDictionary *routeDescription in activeRoutes) {
        RUBusRoute *route = self.routes[agency][routeDescription[@"tag"]];
        route.active = YES;
    }
    
    self.activeRoutes[agency] = [self sortArrayByTitle:[[self.routes[agency] allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active = YES"]]];
    
    NSArray *activeStops = activeConfig[@"stops"];
    NSArray *allStops = [self.stops[agency] allValues];
    
    for (NSArray *stops in allStops) {
        for (RUBusStop *stop in stops) {
            stop.active = NO;
        }
    }
    
    for (NSDictionary *stopDescription in activeStops) {
        NSArray *stops = self.stops[agency][stopDescription[@"title"]];
        for (RUBusStop *stop in stops) {
            stop.active = YES;
        }
    }
    
    NSArray *intermediate = [[self.stops[agency] allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject active];
    }]];
    
    self.activeStops[agency] = [self sortArrayByTitle:intermediate];
}

-(NSArray *)sortArrayByTitle:(NSArray *)array{
    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 title] compare:[obj2 title]];
    }];
}

@end
