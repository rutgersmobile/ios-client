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
#import "RUBusMultipleStopsForSingleLocation.h"
#import "NSArray+Sort.h"
#import "NSPredicate+SearchPredicate.h"
#import "RUNetworkManager.h"
#import "NSURL+RUAdditions.h"

#import "RUDefines.h"

/*
 Some bus information is hosted in the servers..
 
 Informative about the active stops the routing information for each of the routes etc..
 This information is cached ...
 
 The perdictions are obtained from the next bus servers directly
 
 */
#define URLS @{newBrunswickAgency: @"nb-route-config.json", newarkAgency: @"nwk-route-config.json"}
#define ACTIVE_URLS @{newBrunswickAgency: @"nb-active-stops.json", newarkAgency: @"nwk-active-stops.json"}
#define GEO_AREA_WITH_AGENCY @{newBrunswickAgency: @"40.470131,-74.485073|40.549613,-74.416323", newarkAgency: @"40.693134,-74.201145|40.764811,-74.145012"}

@interface RUBusDataAgencyManager ()
@property NSString *agency;


// Main State of the Loading Procedure
//This should be an enum
@property BOOL agencyLoading;
@property BOOL agencyFinishedLoading;
@property NSError *agencyLoadingError;

@property BOOL activeLoading;
@property BOOL activeFinishedLoading;
@property NSError *activeLoadingError;
@property NSDate *lastActiveTaskDate;

/*
 Difference between Agency and Active ?
 Agency refers to the Rutgers Agency : Which gives us information about the routes and buses..
 may be active refers to currently active request ? For a route a bus etc..
 */

/*
 Map between a the route nameas and the route objects
 also for stops
 */
//@property NSDictionary<NSString *, RUBusMultipleStopsForSingleLocation *>* stops; // Multi stop is just an array of stops
/*
 Looks at all the active stops based on information from the RU server and selects all the active routes + stops from all the routes and stops and stores them
 
 */
@property NSArray *activeStops;
@property NSArray *activeRoutes;

@property dispatch_group_t agencyGroup;
@property dispatch_group_t activeGroup;

@end

@implementation RUBusDataAgencyManager


/*
 Just sets the agency and create group to do the work .
 
 */

-(instancetype)initWithAgency:(NSString *)agency
{
    self = [super init];
    if (self) {
        self.agency = agency;
        
        self.agencyGroup = dispatch_group_create();
        self.activeGroup = dispatch_group_create();
    }
    return self;
}

// convenience initalizer
+(instancetype)managerForAgency:(NSString *)agency
{
    return [[self alloc] initWithAgency:agency];
}

// state machien
-(BOOL)agencyConfigNeedsLoad
{
    return !(self.agencyLoading || self.agencyFinishedLoading);
}

#pragma mark - needs to be uncommented
-(void)performWhenAgencyLoaded:(void(^)(NSError *error))handler
{
    if ([self agencyConfigNeedsLoad])
    {
        //[self loadAgencyConfig];
    }
    
    // After all the blocks in the agencyGroup has been excuted , this block will be executed. // read doca for dispatch_group_notify
    dispatch_group_notify(self.agencyGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),^
                          {
                              handler(self.agencyLoadingError);
                          });
    
}

/*
 Load the active stops :
 When not currenly loading and the time since last load > 45
 
 */
-(BOOL)activeStopsAndRoutesNeedLoad
{
    return (!(self.activeLoading || self.activeFinishedLoading) || [[NSDate date] timeIntervalSinceDate:self.lastActiveTaskDate] > 45);
}
/*
 Before the active is loaded the agency is loaded , and if there are no errors then the active is laoded..
 */
-(void)performWhenActiveLoaded:(void(^)(NSError *error))handler
{
    [self performWhenAgencyLoaded:^(NSError *error)
     {
         if (error)
         {
             handler(error);
         }
         else
         {
             if ([self activeStopsAndRoutesNeedLoad])
             {
                 // [self loadActiveStopsAndRoutes];
                 [self getRoutes];
                 [self getStops];
             }
             
             dispatch_group_notify(self.activeGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
                                   {
                                       handler(self.activeLoadingError);
                                   });
         }
     }];
}

/*
 Expects an block which takes a an array of stops and error as input and the
 handler handles all the stops and the erros.
 
 */
-(void)fetchAllStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler
{
    [self performWhenActiveLoaded:^(NSError *error)
     {
         handler([[self.stops allValues] sortByKeyPath:@"title"], error);
     }];
}

-(void)fetchAllRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler
{
    [self performWhenActiveLoaded:^(NSError *error)
     {
         handler([[self.routes allValues] sortByKeyPath:@"title"], error);
     }];
}

-(void)fetchActiveStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler
{
    [self performWhenActiveLoaded:^(NSError *error)
     {
         handler(self.activeStops, error);
     }];
}

-(void)fetchActiveRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler
{
    [self performWhenActiveLoaded:^(NSError *error)
     {
         handler(self.activeRoutes, error);
     }];
}

#pragma mark - nearby api

/*
 get the active stop to nearby to a location :
 > obtain the results from the Rutgers server. Pass in a location and get the places nearby
 
 */
-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void(^)(NSArray *stops, NSError *error))handler
{
    if (!location)
    {
        handler(@[],nil);
        return;
    }
    
    [self performWhenActiveLoaded:^(NSError *error)
     {
         
         NSArray *sortedNearbyStops =
         [
          [self.stops.allValues filteredArrayUsingPredicate: // filter the array such that only stops which are active and within the NERBY_DISTANCE macro are left in the array
           [NSPredicate predicateWithBlock:^
            BOOL(RUBusMultipleStopsForSingleLocation  *stop, NSDictionary *bindings) // self.stops is a an arry of  multiBusStop : So the array is passed into this block
            {
                // the distance to stop caculate the least distance to one of the stops in the multi stops array
                return (stop.active && [self distanceOfStop:stop fromLocation:location] < NEARBY_DISTANCE); // binding dict is done store predicate , not used here.
            }
            ]
           ] // first filter the array . Then sort the array
          
          sortedArrayUsingComparator:^  // sort the array with filtered results so that the stop closer to the location is placed higher <?>
          NSComparisonResult(RUBusMultipleStopsForSingleLocation *stopOne, RUBusMultipleStopsForSingleLocation *stopTwo)
          {
              CLLocationDistance distanceOne = [self distanceOfStop:stopOne fromLocation:location];
              CLLocationDistance distanceTwo = [self distanceOfStop:stopTwo fromLocation:location];
              
              if (distanceOne < distanceTwo)
                  return NSOrderedAscending;
              else if (distanceOne > distanceTwo)
                  return NSOrderedDescending;
              else
                  return NSOrderedSame;
          }
          ];
         handler(sortedNearbyStops, error);
     }];
}

/*
 poor naming : multiStop has multipe stops in it and the distance of stop finds the distance of the closest stop in the multi stop array ..
 */
-(CLLocationDistance)distanceOfStop:(RUBusMultipleStopsForSingleLocation *)multiStop fromLocation:(CLLocation *)location
{
    CLLocationDistance minDistance = -1;
    for (RUBusStop *stop in multiStop.stops)
    {
        CLLocationDistance distance = [stop.location distanceFromLocation:location];
        if (minDistance == -1 || distance < minDistance)
        {
            minDistance = distance;
        }
    }
    return minDistance;
}

#pragma mark - searching

/*
 Used to display the resuls in the serach table view <?>
 */
-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *routes, NSArray *stops, NSError *error))handler
{
    
    [self performWhenAgencyLoaded:^(NSError *error)
     {
         NSPredicate *predicate = [NSPredicate predicateForQuery:query keyPath:@"title"];
         NSArray *routes = [self.routes.allValues filteredArrayUsingPredicate:predicate];
         NSArray *stops = [self.stops.allValues filteredArrayUsingPredicate:predicate];
         handler(routes,stops,error);
     }];
}
#pragma mark transloc methods
-(NSString*)baseURL {
    return @"https://transloc-api-1-2.p.mashape.com/";
}

-(NSString*)buildURLStringWith:(NSString*)argument {
    return [[self baseURL] stringByAppendingString:argument];
}

-(NSDictionary*)buildParameters: (NSString*) agencyLocation{
    return @{@"agencies": @"1323", @"geo_area": agencyLocation};
}
//Add completion handlers here and add to dispatch group
#warning handle dictionary not parsing, some failure
-(void)getRoutes {
    dispatch_group_enter(self.activeGroup);
    
    self.activeLoading = YES;
    self.activeFinishedLoading = NO;
    self.activeLoadingError = nil;
    [[RUNetworkManager transLocSessionManager] GET:[RUNetworkManager buildURLStringWith: @"routes.json"] parameters:[RUNetworkManager buildParameters: GEO_AREA_WITH_AGENCY[self.agency]] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            [self parseRoutes:responseObject[@"data"][@"1323"]:self.agency];
            self.activeFinishedLoading = YES;
            self.lastActiveTaskDate = [NSDate date];
        }
        else
        {
            self.activeFinishedLoading = NO;
        }
        // set state of loading task
        self.activeLoading = NO;
        self.activeLoadingError = nil;
        dispatch_group_leave(self.activeGroup);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.activeLoading = NO;
        self.activeFinishedLoading = NO;
        self.activeLoadingError = error;
        dispatch_group_leave(self.activeGroup);
    }];
}

-(void)getStops {
    dispatch_group_enter(self.activeGroup);
    
    self.activeLoading = YES;
    self.activeFinishedLoading = NO;
    self.activeLoadingError = nil;
    [[RUNetworkManager transLocSessionManager] GET:[RUNetworkManager buildURLStringWith: @"stops.json"] parameters:[RUNetworkManager buildParameters: GEO_AREA_WITH_AGENCY[self.agency]] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            [self parseStops: responseObject[@"data"]: self.agency];
            self.activeFinishedLoading = YES;
            self.lastActiveTaskDate = [NSDate date];
        }
        else
        {
            self.activeFinishedLoading = NO;
        }
        dispatch_group_leave(self.activeGroup);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.activeLoading = NO;
        self.activeFinishedLoading = NO;
        self.activeLoadingError = error;
        dispatch_group_leave(self.activeGroup);
    }];
}

-(void)parseStops:(NSArray*)stopArray :(NSString*) agency {
    NSMutableArray* mutableStopArray = [NSMutableArray array];
    NSMutableDictionary* mutableStopDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary* stop in stopArray) {
        NSDictionary* stopTemp = stop;
        RUBusStop* stopObj = [[RUBusStop alloc] initWithDictionary:stopTemp];
        stopObj.agency = agency;
        if ([stopObj active]) {
            BOOL isTrue = NO;
            for (NSString* routeId in stopObj.routes) {
                RUBusRoute* checkIfActive = self.routes[routeId];
                if (checkIfActive.active) {
                    isTrue = YES;
                    break;
                }
            }
            if (isTrue) {
                [mutableStopArray addObject:stopObj];
                NSString* stopId = [NSString stringWithFormat:@"%ld", (long) stopObj.stopId];
                [mutableStopDictionary setValue:stopObj forKey: stopId];
            }
        }
    }
    self.stops = mutableStopDictionary;
    self.activeStops = mutableStopArray;
}

-(void)parseRoutes:(NSArray*)routeArray :(NSString*) agency {
    NSMutableArray* mutableRouteArray = [NSMutableArray array];
    NSMutableDictionary* mutableRouteDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary* route in routeArray) {
        NSDictionary* routeTemp = route;
        RUBusRoute* routeObj = [[RUBusRoute alloc] initWithDictionary:routeTemp];
        routeObj.agency = agency;
        if ([routeObj active]) {
            [mutableRouteArray addObject:routeObj];
            [mutableRouteDictionary setValue:routeObj forKey:routeObj.route_id];
        }
    }
    self.routes = mutableRouteDictionary;
    self.activeRoutes = mutableRouteArray;
}

-(id)reconstituteSerializedItemWithName:(NSString *)name type:(NSString *)type
{
    name = name.stringByRemovingPercentEncoding;
    if ([type isEqualToString:@"stop"])
    {
        for (RUBusMultipleStopsForSingleLocation *stop in self.stops.allValues)
        {
            if ([stop.title.lowercaseString isEqualToString:[name lowercaseString]]) // both values are converted to lower case string before comparison.
            {
                return stop;
            }
        }
    }
    else if ([type isEqualToString:@"route"])
    {
        for (RUBusRoute *route in self.routes.allValues)
        {
            if ([route.tag.lowercaseString isEqualToString:[name lowercaseString]])
            {
                return route;
            }
        }
    }
    return nil;
}

@end
