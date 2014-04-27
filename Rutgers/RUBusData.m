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

NSString const *newBrunswickAgency = @"rutgers";
NSString const *newarkAgency = @"rutgers-newark";

/*
const NSString *baseURL = @"http://webservices.nextbus.com/service/publicXMLFeed?";
const NSString *routeConfig = @"routeConfig";

const NSString *route = @"route";
const NSString *stop = @"stop";*/

@interface RUBusData () <CLLocationManagerDelegate>
@property (nonatomic) AFHTTPSessionManager *jsonSessionManager;
@property (nonatomic) AFHTTPSessionManager *xmlSessionManager;
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation RUBusData
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
        self.xmlSessionManager.responseSerializer = [AFTBXMLResponseSerializer serializer];
        self.jsonSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/xml",nil];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 100; // whenever we move
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
-(void)dealloc{
    [self stopFindingNearbyStops];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* location = [locations lastObject];
    
    NSDictionary *stops = [self stopsNearLocation:location];
    self.nearbyStops = stops;
    
    [self.delegate busData:self didUpdateNearbyStops:stops];
}

#define NEARBY_DISTANCE 500
-(NSDictionary *)stopsNearLocation:(CLLocation *)location{

    NSMutableDictionary *nearbyStops = [NSMutableDictionary dictionary];
    
    for (NSString *agency in @[newBrunswickAgency,newarkAgency]) {
        NSMutableArray *nearbyStopsForAgency = [NSMutableArray array];
        
        NSDictionary *stops = self.stops[agency];
        [stops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CLLocationDistance distance = [self distanceOfStops:obj fromLocation:location];
            if (distance < NEARBY_DISTANCE) {
                [nearbyStopsForAgency addObject:obj];
            }
            /*
            RUBusStop *busStop = [obj firstObject];
            if (busStop.active) {
                CLLocationDistance distance = [busStop.location distanceFromLocation:location];
                if (distance < NEARBY_DISTANCE) {
                    [nearbyStopsForAgency addObject:obj];
                }
            }*/
        }];
        
        nearbyStops[agency] = [nearbyStopsForAgency sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            //RUBusStop *busStopOne = [obj1 firstObject];
           // RUBusStop *busStopTwo = [obj2 firstObject];
            
        //    CLLocationDistance distanceOne = [busStopOne.location distanceFromLocation:location];
         //   CLLocationDistance distanceTwo = [busStopTwo.location distanceFromLocation:location];
            
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
-(void)getAgencyConfigWithCompletion:(void (^)(void))completionBlock{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self.jsonSessionManager GET:@"https://rumobile.rutgers.edu/1/rutgersrouteconfig.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseRouteConfig:responseObject forAgency:newBrunswickAgency];
            dispatch_group_leave(group);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    dispatch_group_enter(group);
    [self.jsonSessionManager GET:@"https://rumobile.rutgers.edu/1/rutgers-newarkrouteconfig.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseRouteConfig:responseObject forAgency:newarkAgency];
            dispatch_group_leave(group);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self updateActiveStopsAndRoutesWithCompletion:completionBlock];
    });

}

-(void)updateActiveStopsAndRoutesWithCompletion:(void (^)(void))completionBlock{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self.jsonSessionManager GET:@"https://rumobile.rutgers.edu/1/nbactivestops.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseActiveStops:responseObject forAgency:newBrunswickAgency];
            dispatch_group_leave(group);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    
    dispatch_group_enter(group);
    [self.jsonSessionManager GET:@"https://rumobile.rutgers.edu/1/nwkactivestops.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parseActiveStops:responseObject forAgency:newarkAgency];
            dispatch_group_leave(group);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), completionBlock);
}

-(void)getPredictionsForStops:(NSArray *)stops inAgency:(NSString *)agency withCompletion:(void (^)(NSArray *response))completionBlock{
    [self.xmlSessionManager GET:[self urlStringForItem:stops inAgency:agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *response = [self parsePredictions:responseObject];
        completionBlock(response);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil);
    }];
}

-(void)getPredictionsForRoute:(RUBusRoute *)route inAgency:(NSString *)agency withCompletion:(void (^)(NSArray *response))completionBlock{
    [self.xmlSessionManager GET:[self urlStringForItem:route inAgency:agency] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *response = [self parsePredictions:responseObject];
        completionBlock(response);
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
            for (RUBusRoute *route in stop.activeRoutes) {
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
-(void)parseRouteConfig:(NSDictionary *)routeConfig forAgency:(NSString *)agency{
    
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

-(void)parseActiveStops:(NSDictionary *)routeConfig forAgency:(NSString *)agency{
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

-(NSArray *)parsePredictions:(TBXML *)response{
    NSMutableArray *array = [NSMutableArray array];
    [TBXML iterateElementsForQuery:@"predictions" fromElement:response.rootXMLElement withBlock:^(TBXMLElement *element) {
        NSMutableDictionary *subitem = [NSMutableDictionary dictionary];
        [TBXML iterateAttributesOfElement:element withBlock:^(TBXMLAttribute *attribute, NSString *attributeName, NSString *attributeValue) {
            subitem[attributeName] = attributeValue;
        }];
        TBXMLElement *directionElement = [TBXML childElementNamed:@"direction" parentElement:element];
        if (directionElement) {
            subitem[@"directionTitle"] = [TBXML valueOfAttributeNamed:@"title" forElement:directionElement];
            NSMutableArray *predictions = [NSMutableArray array];
            [TBXML iterateElementsForQuery:@"prediction" fromElement:directionElement withBlock:^(TBXMLElement *element) {
                NSMutableDictionary *prediction = [NSMutableDictionary dictionary];
                [TBXML iterateAttributesOfElement:element withBlock:^(TBXMLAttribute *attribute, NSString *attributeName, NSString *attributeValue) {
                    prediction[attributeName] = attributeValue;
                }];
                [predictions addObject:prediction];
            }];
            subitem[@"predictions"] = predictions;
            subitem[@"arrivalTimes"] = [self arrivalTimeDescriptionForPredictions:predictions];
        } else {
            subitem[@"directionTitle"] = subitem[@"dirTitleBecauseNoPredictions"];
            subitem[@"arrivalTimes"] = @"No predictions available.";
        }
        [array addObject:subitem];
    }];
    return [array copy];
}

-(NSString *)arrivalTimeDescriptionForPredictions:(NSArray *)predictions{
    NSMutableString *string = [[NSMutableString alloc] init];
    [predictions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *prediction = obj;
        NSString *minutes = prediction[@"minutes"];
        if ([string isEqualToString:@""]) {
            [string appendString:minutes];
        } else {
            [string appendFormat:@", %@",minutes,nil];
        }
        if (idx == 2) *stop = YES;
    }];
    [string appendString:@" minutes"];
    return string;
}
@end
