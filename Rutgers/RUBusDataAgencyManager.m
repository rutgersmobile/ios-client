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
#define URLS @{newBrunswickAgency: @"rutgersrouteconfig.txt", newarkAgency: @"rutgers-newarkrouteconfig.txt"}
#define ACTIVE_URLS @{newBrunswickAgency: @"nbactivestops.txt", newarkAgency: @"nwkactivestops.txt"}

@interface RUBusDataAgencyManager ()
@property NSString *agency;


// Main State of the Loading Procedure
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


@property NSDictionary<NSString *, RUBusMultipleStopsForSingleLocation *>* stops; // Multi stop is just an array of stops
@property NSDictionary<NSString *, RUBusRoute *>* routes;

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

-(void)performWhenAgencyLoaded:(void(^)(NSError *error))handler
{
    if ([self agencyConfigNeedsLoad])
    {
        [self loadAgencyConfig];
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
                [self loadActiveStopsAndRoutes];
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

#pragma mark - api requests

/*
    Load information about the agency from the rutgers servers
    we use the session Manager from the network manager to get this information
 */
-(void)loadAgencyConfig
{
    dispatch_group_enter(self.agencyGroup); // the following part is done asynchronusly. speficies a block of work to be done asynchronously
    
    self.agencyLoading = YES;
    self.agencyFinishedLoading = NO;
    self.agencyLoadingError = nil;
    
    [
     [RUNetworkManager sessionManager]
        GET:URLS[self.agency] parameters:nil // URLS contain the names of the files which contains the data that is used
            success:^
                (NSURLSessionDataTask *task, id responseObject)
                {
                    if ([responseObject isKindOfClass:[NSDictionary class]])
                    {
                        [self parseRouteConfig:responseObject]; // parse the json object // the serialization is done by the session manager's compound serailizer
                         self.agencyFinishedLoading = YES;
                    }
                    else
                    {
                        self.agencyFinishedLoading = NO;
                    }
                    self.agencyLoadingError = nil;
                    self.agencyLoading = NO;
                    
                    dispatch_group_leave(self.agencyGroup);
                }
            failure:^
                (NSURLSessionDataTask *task, NSError *error)
                {
                    self.agencyLoading = NO;
                    self.agencyFinishedLoading = NO;
                    self.agencyLoadingError = error;
                    dispatch_group_leave(self.agencyGroup);
                }
     ];
    
}

/*
    The active stops are cached in the rutgers server and this function obtains the data from them
 */
-(void)loadActiveStopsAndRoutes
{
    dispatch_group_enter(self.activeGroup);
    
    self.activeLoading = YES;
    self.activeFinishedLoading = NO;
    self.activeLoadingError = nil;
    
    [
     [RUNetworkManager sessionManager]
        GET:ACTIVE_URLS[self.agency] parameters:nil
            success:^
                (NSURLSessionDataTask *task, id responseObject)
                {
                    if ([responseObject isKindOfClass:[NSDictionary class]])
                    {
                        [self parseActiveStopsAndRoutes:responseObject];
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
                    
                }
            failure:^
                (NSURLSessionDataTask *task, NSError *error)
                {
                    // set the state of the loading
                    self.activeLoading = NO;
                    self.activeFinishedLoading = NO;
                    self.activeLoadingError = error;
                    
                    dispatch_group_leave(self.activeGroup);
                }
     
    ];
    
}

/*
    Format change according to https://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf
 
    No need for @"&stops=%@|null|%@" , @"&stops=%@|%@" will do.
 
 */
#warning make sure the format change is not causing problems

#pragma mark - predictions for multi stops
static NSString *const formatForNextBusMultiStopPrediction = @"&stops=%@|%@";

/*
    The Url for obtain data from next bus api
    
    We use the predictionsForMultiStops command from next bus to obtain the information ..
 
    Uses a particular format and we add the stops and routes to it.
 
    Called By BusDataLoadingManager
 
    In the next bus api , this commnad is called , predictionForMultiStops
 
    DIfferent prediction for Routes and Multi Stops
 
 */
-(NSString *)urlStringForItem:(id)item
{
   
    if(DEV)
    {
        NSMutableString * urlTestString = [NSMutableString stringWithString:@"http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&stops=N|6997&stops=N|3909"];
        return  [urlTestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    /*
        TESTING
         
     
     */
    NSMutableString *urlString = [NSMutableString stringWithString:@"http://webservices.nextbus.com/service/publicXMLFeed?a=rutgers&command=predictionsForMultiStops"];

    if ([item isKindOfClass:[RUBusMultipleStopsForSingleLocation class]])
    {
        RUBusMultipleStopsForSingleLocation *multiStop = item;
        NSArray *stops = multiStop.stops;

        for (RUBusStop *stop in stops)
        {
            for (NSString *routeTag in stop.routes)
            {
                [urlString appendFormat:formatForNextBusMultiStopPrediction,routeTag,stop.tag];
            }
        }
        
    }
    else if([item isKindOfClass:[RUBusRoute class]])
    {
        RUBusRoute *route = item;
        for (NSString *stopTag in route.stops)
        {
            [urlString appendFormat:formatForNextBusMultiStopPrediction ,route.tag,stopTag];
        }
    }
    
    NSLog(@"URL : %@" , urlString);
    
    return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}


#pragma mark - api response parsing

/*
    Obtains data from the Rutgers servers and then uses them to create the Bus Stops , Routes And Multi Stop objects
 
    called by the load agency config in this class.
    Based on the agency ( NB , vs Newark ) the corresponding object is obtained from the RU server from the *routeConfig.txt files
    This json dict is passecd to this function for pasing
 
 */

-(void)parseRouteConfig:(NSDictionary *)routeConfig
{
    
    NSMutableDictionary *routesByTag = [NSMutableDictionary dictionary];
    NSMutableDictionary *stopsByTitle = [NSMutableDictionary dictionary]; // <q> difference between stops by tag and stops by title
    NSMutableDictionary *stopsByTag = [NSMutableDictionary dictionary];
    
    //pulls routes out of response json
   /*
    
        The routeConfig object contains
        routes : information about each route 
                        > direction
                        > queries : usullay empty
                        > stops  : array of stops
                        > title : bus title
    
        sorted routes : 
                  An array of routes sorted accounding to alphabetical order
        
        sorted stops : 
                 array of sorted stops
    
        stops : 
                array of stops : which each stop having 
                        > lat 
                        > lon
                        > quries
                        > routes 
                        > stopId  // stopID -> a number uses by nextbus for the stop
                        > title    -> name of the stop
    
        
                odity : 
                    there is allison and allison_a  && many others with the same naming format
                        > different stops , near the same location but different routes and location
                    also exists 
                        libofsci and libofsciw
                            > same stop  , location and id , but  routes moving in different direction ?
    
                    issues here :      
                            > two stops sometimes nearby same location 
                            > at a single stop , two different direction
                                    eg Like at the hill center where the buses go back to Rutgers Student Center and the buses which goes towards livingston
    */
    
    
    NSDictionary *routes = routeConfig[@"routes"];
    
    for (NSString *routeTag in routes)
    {
        //allocs a route with its json representation
        RUBusRoute *route = [[RUBusRoute alloc] initWithDictionary:routes[routeTag]];
        route.agency = self.agency;
        route.tag = routeTag;
        routesByTag[routeTag] = route;
    }
    
    //pulls stops out of response json
    NSDictionary *stops = routeConfig[@"stops"];
    
    for (NSString *stopTag in stops)
    {
        //allocs a stop with its json representation
        RUBusStop *stop = [[RUBusStop alloc] initWithDictionary:stops[stopTag]];
        stop.agency = self.agency;
        stop.tag = stopTag;
        stopsByTag[stopTag] = stop;
       
       
        // What is the distinction between stop and multi stop ?
        /*
                BusMultiStop corresponds to cases where there are multipe Stops Near a Place 
                The information mentioned in the oddity section were
            */
        
        //checks if the title has been seen yet
        /*
                Multipe Stops corresponding to the same location will have the same title. So we combine them based on the title
            */
        RUBusMultipleStopsForSingleLocation *stopsForTitle = stopsByTitle[stop.title]; // dict of dict : stopByTitle : contains the multiple Title ( titles of the location ) : and each of the titles will have a list corresponding to the stops corresponsing to that single location
        
        if (!stopsForTitle) // If the title was not seen before create new dict , else add the new stop with the same title as was seen previously , to the title dict in the stopsByTitle dict
        {
            //if not make an array to hold stops with this title
            stopsForTitle = [[RUBusMultipleStopsForSingleLocation alloc] init];
            stopsByTitle[stop.title] = stopsForTitle;
        }
        
        //add the stop to the array of stops with identical titles
        [stopsForTitle addStopsObject:stop];
    }
    
    //looping over the route objects we have just made
    for (NSString *routeTag in routesByTag)
    {
        RUBusRoute *route = routesByTag[routeTag];
        
        //retrieve the temp array of stop tags
        NSArray *stopTagsInRoute = route.stops; // each route has multipe stops
        
        
        for (NSString *stopTag in stopTagsInRoute)
        {
            RUBusStop *stop = stopsByTag[stopTag]; // get the stop associated with the stops in the route
            stop.routes = [stop.routes arrayByAddingObject:routeTag]; // add the route going through them to each stop
        }
    }
    
    self.stops = stopsByTitle; // collections of stops : ( multiple stops correcpsonsing to single location is stored as a single stop
    self.routes = routesByTag;
}
/*
    The infromation about the Active Stops + Routes is obtained from the Ruters servers and added to objects here.
 
    called in the loadActiveStops method
 */

-(void)parseActiveStopsAndRoutes:(NSDictionary *)activeConfig
{
    NSSet *activeRouteTags = [NSSet setWithArray:[activeConfig[@"routes"] valueForKey:@"tag"]];
    NSMutableArray *activeRoutes = [NSMutableArray array];
    
    for (RUBusRoute *route in self.routes.allValues) // the agency has to be build and all its stops and routes stored before this function can be called
    {
        BOOL active = [activeRouteTags containsObject:route.tag]; // check if the route is active
        route.active = active;
        if (active)
        {
            [activeRoutes addObject:route];
        }
    }
    
    NSSet *activeStopTitles = [NSSet setWithArray:[activeConfig[@"stops"] valueForKey:@"title"]];
    NSMutableArray *activeStops = [NSMutableArray array];

    for (RUBusMultipleStopsForSingleLocation *stop in self.stops.allValues)
    {
        BOOL active = [activeStopTitles containsObject:stop.title];
        stop.active = active;
        if (active)
        {
            [activeStops addObject:stop];
        }
    }
    
    self.activeRoutes = [activeRoutes sortByKeyPath:@"title"];

    self.activeStops = [activeStops sortByKeyPath:@"title"];
}

/*
    used to recreate the route or stop from just the string of the route and tag. 
    Used for example in the favourties implementation
 
 
    Returns the route or multiple Bus object
 
 */
-(id)reconstituteSerializedItemWithName:(NSString *)name type:(NSString *)type
{
    name = name.stringByRemovingPercentEncoding;
    if ([type isEqualToString:@"stop"])
    {
        for (RUBusMultipleStopsForSingleLocation *stop in self.stops.allValues)
        {
            if ([stop.title.lowercaseString isEqualToString:name])
            {
                return stop;
            }
        }
    }
    else if ([type isEqualToString:@"route"])
    {
        for (RUBusRoute *route in self.routes.allValues)
        {
            if ([route.tag.lowercaseString isEqualToString:name])
            {
                return route;
            }
        }
    }
    return nil;
}

@end
