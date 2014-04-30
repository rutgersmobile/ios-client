//
//  RUBusData.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusData.h"
#import <AFNetworking.h>

#import "RUBusRoute.h"
#import "RUBusStop.h"
#import "AFXMLResponseSerializer.h"

NSString const *newBrunswickAgency = @"rutgers";
NSString const *newarkAgency = @"rutgers-newark";

#define NEARBY_DISTANCE 300

@interface RUBusData () <CLLocationManagerDelegate>
@property (nonatomic) AFHTTPSessionManager *jsonSessionManager;
@property (nonatomic) AFHTTPSessionManager *xmlSessionManager;
@property (nonatomic) CLLocationManager *locationManager;
@property dispatch_group_t agencyGroup;
@property dispatch_group_t activeGroup;
//@property NSDate *fetchDate;
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
        
        self.jsonSessionManager = [AFHTTPSessionManager manager];

        self.jsonSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.jsonSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",nil];
        
        self.xmlSessionManager = [AFHTTPSessionManager manager];
        self.xmlSessionManager.responseSerializer = [AFXMLResponseSerializer serializer];
        self.jsonSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",nil];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 25; // whenever we move 25 m
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        self.locationManager.delegate = self;
    }
    return self;
}
#pragma nearby api
-(void)startFindingNearbyStops{
    [self.locationManager startUpdatingLocation];
}
-(void)stopFindingNearbyStops{
    [self.locationManager stopUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* location = [locations lastObject];
    dispatch_group_notify(self.activeGroup, dispatch_get_main_queue(), ^{
        NSDictionary *nearbyStops = [self stopsNearLocation:location];
        self.nearbyStops = nearbyStops;
        [self.delegate busData:self didUpdateNearbyStops:nearbyStops];
    });
}

-(NSDictionary *)stopsNearLocation:(CLLocation *)location{
    NSMutableDictionary *nearbyStops = [NSMutableDictionary dictionary];
    
    for (NSString *agency in @[newBrunswickAgency,newarkAgency]) {
        NSMutableArray *nearbyStopsForAgency = [NSMutableArray array];
        
        NSDictionary *stops = self.stops[agency];
        [stops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            BOOL active = NO;
            for (RUBusStop *busStop in obj) {
                if (busStop.active) {
                    active = YES;
                    break;
                }
            }
            
            if (active) {
                CLLocationDistance distance = [self distanceOfStops:obj fromLocation:location];
                if (distance < NEARBY_DISTANCE) {
                    [nearbyStopsForAgency addObject:obj];
                }
            }
        }];
        
        nearbyStops[agency] = [nearbyStopsForAgency sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CLLocationDistance distanceOne = [self distanceOfStops:obj1 fromLocation:location];
            CLLocationDistance distanceTwo = [self distanceOfStops:obj2 fromLocation:location];
            
            if (distanceOne < distanceTwo) return NSOrderedAscending;
            if (distanceOne > distanceTwo) return NSOrderedDescending;
            return NSOrderedSame;
        }];
    }
    return nearbyStops;
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
#pragma mark api convienience functions
-(void)getAgencyConfig{
    dispatch_group_t group = dispatch_group_create();
    self.agencyGroup = group;
    
    dispatch_group_enter(group);
    [self getAgencyConfigForAgency:newBrunswickAgency inCompletionGroup:group];
    
    dispatch_group_enter(group);
    [self getAgencyConfigForAgency:newarkAgency inCompletionGroup:group];
    
}

-(void)getAgencyConfigForAgency:(const NSString *)agency inCompletionGroup:(dispatch_group_t)group{
    NSDictionary *urls = @{newBrunswickAgency: @"https://rumobile.rutgers.edu/1/rutgersrouteconfig.txt", newarkAgency: @"https://rumobile.rutgers.edu/1/rutgers-newarkrouteconfig.txt"};
    [self.jsonSessionManager GET:urls[agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseRouteConfig:responseObject forAgency:agency];
            dispatch_group_leave(group);
        } else {
            [self getAgencyConfigForAgency:agency inCompletionGroup:group];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self getAgencyConfigForAgency:agency inCompletionGroup:group];
    }];
    
}

-(void)updateActiveStopsAndRoutesWithCompletion:(void (^)(void))completionBlock{
    if (!self.agencyGroup) {
        [self getAgencyConfig];
    }
    dispatch_group_notify(self.agencyGroup, dispatch_get_main_queue(), ^{

        dispatch_group_t group = dispatch_group_create();
        self.activeGroup = group;
        
        dispatch_group_enter(group);
        [self updateActiveStopsAndRoutesForAgency:newBrunswickAgency inCompletionGroup:group];
        
        dispatch_group_enter(group);
        [self updateActiveStopsAndRoutesForAgency:newarkAgency inCompletionGroup:group];
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
  //          self.fetchDate = [NSDate date];
            completionBlock();
        });
    });
}

-(void)updateActiveStopsAndRoutesForAgency:(const NSString *)agency inCompletionGroup:(dispatch_group_t)group{
    NSDictionary *urls = @{newBrunswickAgency: @"https://rumobile.rutgers.edu/1/nbactivestops.txt", newarkAgency: @"https://rumobile.rutgers.edu/1/nwkactivestops.txt"};
    [self.jsonSessionManager GET:urls[agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseActiveStops:responseObject forAgency:agency];
            dispatch_group_leave(group);
        } else {
            [self updateActiveStopsAndRoutesForAgency:agency inCompletionGroup:group];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self updateActiveStopsAndRoutesForAgency:agency inCompletionGroup:group];
    }];
}

-(void)getPredictionsForStops:(NSArray *)stops inAgency:(NSString *)agency withCompletion:(void (^)(NSArray *response))completionBlock{
    [self getPredictionsForItem:stops inAgency:agency withCompletion:completionBlock];
}

-(void)getPredictionsForRoute:(RUBusRoute *)route inAgency:(NSString *)agency withCompletion:(void (^)(NSArray *response))completionBlock{
    [self getPredictionsForItem:route inAgency:agency withCompletion:completionBlock];
}
-(void)getPredictionsForItem:(id)item inAgency:(NSString *)agency withCompletion:(void (^)(NSArray *response))completionBlock{
    [self.xmlSessionManager GET:[self urlStringForItem:item inAgency:agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id predictions = responseObject[@"predictions"];
            completionBlock(predictions);
        } else {
            completionBlock(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil);
    }];
}

static NSString *const format = @"&stops=%@|null|%@";

-(NSString *)urlStringForItem:(id)item inAgency:(NSString *)agency{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?a=%@&command=predictionsForMultiStops",agency];
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *stops = item;
        for (RUBusStop *stop in stops){
            NSArray *routes = [stop.activeRoutes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 title] compare:[obj2 title]];
            }]; //sort here
            for (RUBusRoute *route in routes) {
                [urlString appendFormat:format,route.tag,stop.tag];
            }
        }
        return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else if ([item isKindOfClass:[RUBusRoute class]]){
        RUBusRoute *route = item;
        for (RUBusStop *stop in route.activeStops){
                [urlString appendFormat:format,route.tag,stop.tag];
        }
        return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark api response parsing
-(void)parseRouteConfig:(NSDictionary *)routeConfig forAgency:(const NSString *)agency{
    
    NSMutableDictionary *routesByTag = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTitle = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTag = [NSMutableDictionary dictionary];

    //pulls routes out of response json
    NSDictionary *routes = routeConfig[@"routes"];
    for (NSString *routeTag in routes) {
        //allocs a route with its json representation
        RUBusRoute *route = [[RUBusRoute alloc] initWithDictionary:routes[routeTag]];
        route.tag = routeTag;
        routesByTag[routeTag] = route;
    }
    
    //pulls stops out of response json
    NSDictionary *stops = routeConfig[@"stops"];
    for (NSString *stopTag in stops) {
        //allocs a stop with its json representation
        RUBusStop *stop = [[RUBusStop alloc] initWithDictionary:stops[stopTag]];
        stop.tag = stopTag;
        stopsByTag[stopTag] = stop;
        
        //checks if the title has been seen yet
        NSMutableArray *stopsForTitle = stopsByTitle[stop.title];
        if (!stopsForTitle) {
            //if not make an array to hold stops with this title
            stopsForTitle = [NSMutableArray array];
            stopsByTitle[stop.title] = stopsForTitle;
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

-(void)parseActiveStops:(NSDictionary *)routeConfig forAgency:(const NSString *)agency{
    NSArray *routes = routeConfig[@"routes"];
    for (NSDictionary *routeDescription in routes) {
        RUBusRoute *route = self.routes[agency][routeDescription[@"tag"]];
        route.active = YES;
    }
    
    self.activeRoutes[agency] = [[[self.routes[agency] allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active = YES"]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    NSArray *stops = routeConfig[@"stops"];
    for (NSDictionary *stopDescription in stops) {
        NSArray *stops = self.stops[agency][stopDescription[@"title"]];
        for (RUBusStop *stop in stops) {
            stop.active = YES;
        }
    }
    
    NSArray *intermediate = [[self.stops[agency] allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSArray *array = evaluatedObject;
        for (RUBusStop *stop in array) {
            if (stop.active) {
                return true;
            }
        }
        return false;
    }]];
    
    self.activeStops[agency] = [intermediate sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[[obj1 firstObject] title] compare:[[obj2 firstObject] title]];
    }];
}

@end
