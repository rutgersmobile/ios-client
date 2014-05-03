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

@property NSMutableDictionary *stops;
@property NSMutableDictionary *routes;
@property NSMutableDictionary *allStopsAndRoutes;

@property NSMutableDictionary *activeStops;
@property NSMutableDictionary *activeRoutes;

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
        self.allStopsAndRoutes = [NSMutableDictionary dictionary];
        
        self.jsonSessionManager = [AFHTTPSessionManager manager];

        self.jsonSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.jsonSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",nil];
        
        self.xmlSessionManager = [AFHTTPSessionManager manager];
        self.xmlSessionManager.responseSerializer = [AFXMLResponseSerializer serializer];
        self.xmlSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",@"text/xml",nil];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 25; // whenever we move 25 m
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        self.locationManager.delegate = self;
        
        [self getAgencyConfig];
    }
    return self;
}
#pragma mark - nearby api
-(void)startFindingNearbyStops{
    //NSAssert(!self.activeGroup, @"The call to update stops and routes must be made first");
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
#pragma mark - network api functions
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

-(void)updateActiveStopsAndRoutesWithCompletion:(void (^)(NSDictionary *activeStops, NSDictionary *activeRoutes))completionBlock{

    dispatch_group_t group = dispatch_group_create();
    self.activeGroup = group;
    
    //start blocking the group
    dispatch_group_enter(group);
    
    dispatch_group_notify(self.agencyGroup, dispatch_get_main_queue(), ^{
        dispatch_group_enter(group);
        [self updateActiveStopsAndRoutesForAgency:newBrunswickAgency inCompletionGroup:group];
        
        dispatch_group_enter(group);
        [self updateActiveStopsAndRoutesForAgency:newarkAgency inCompletionGroup:group];
        
        //end blocking the group, pairs with the call above
        dispatch_group_leave(group);

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            completionBlock([self.activeStops copy], [self.activeRoutes copy]);
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
#pragma mark - predictions api
-(void)getPredictionsForStops:(NSArray *)stops withCompletion:(void (^)(NSArray *response))completionBlock{
    [self getPredictionsForItem:stops withCompletion:completionBlock];
}

-(void)getPredictionsForRoute:(RUBusRoute *)route withCompletion:(void (^)(NSArray *response))completionBlock{
    [self getPredictionsForItem:route withCompletion:completionBlock];
}
-(void)getPredictionsForItem:(id)item withCompletion:(void (^)(NSArray *response))completionBlock{
    [self.xmlSessionManager GET:[self urlStringForItem:item] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id predictions = responseObject[@"predictions"];
            completionBlock(predictions);
        } else {
            [self getPredictionsForItem:item withCompletion:completionBlock];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self getPredictionsForItem:item withCompletion:completionBlock];
    }];
}

static NSString *const format = @"&stops=%@|null|%@";

-(NSString *)urlStringForItem:(id)item{

    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *stops = item;
        NSString *agency = [(RUBusStop *)[stops firstObject] agency];

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
            return [[self.routes[agency][routeTagOne] title] compare:[self.routes[agency][routeTagTwo] title]];
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
    dispatch_group_notify(self.activeGroup, dispatch_get_main_queue(), ^{
        
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
            BOOL one;
            NSString *titleOne;
            if ([obj1 isKindOfClass:[RUBusRoute class]]) {
                one = [beginsWithPredicate evaluateWithObject:obj1];
                titleOne = [obj1 title];
            } else {
                RUBusStop *stop = [obj1 firstObject];
                one = [beginsWithPredicate evaluateWithObject:stop];
                titleOne = stop.title;
            }
            
            BOOL two;
            NSString *titleTwo;
            if ([obj2 isKindOfClass:[RUBusRoute class]]) {
                two = [beginsWithPredicate evaluateWithObject:obj2];
                titleTwo = [obj2 title];
            } else {
                RUBusStop *stop = [obj2 firstObject];
                two = [beginsWithPredicate evaluateWithObject:stop];
                titleTwo = stop.title;
            }
            
            if (one && !two) {
                return NSOrderedAscending;
            } else if (!one && two) {
                return NSOrderedDescending;
            }
            return [titleOne compare:titleTwo];
        }];
        
        completionBlock(results);
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

-(void)parseActiveStops:(NSDictionary *)routeConfig forAgency:(const NSString *)agency{
    NSArray *activeRoutes = routeConfig[@"routes"];
    NSArray *routes = [self.routes[agency] allValues];
    
    for (RUBusRoute *route in routes) {
        route.active = NO;
    }
    
    for (NSDictionary *routeDescription in activeRoutes) {
        RUBusRoute *route = self.routes[agency][routeDescription[@"tag"]];
        route.active = YES;
    }
    
    self.activeRoutes[agency] = [[[self.routes[agency] allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active = YES"]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    NSArray *activeStops = routeConfig[@"stops"];
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
