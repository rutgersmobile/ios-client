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
#import "RUBusPrediction.h"
#import "RUNetworkManager.h"
#import "RUDefines.h"
#import "RUBusArrival.h"
#import <MapKit/MapKit.h>

NSString * const newBrunswickAgency = @"rutgers";
NSString * const newarkAgency = @"rutgers-newark";

@interface RUBusDataLoadingManager ()
@property NSDictionary *agencyManagers;
@end

@implementation RUBusDataLoadingManager
/*
 Use a single manager to load the data for all the buses
 */
+(instancetype)sharedInstance{
    static RUBusDataLoadingManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedManager = [[RUBusDataLoadingManager alloc] init];
                  });
    return sharedManager;
}

+(NSString *)titleForAgency:(NSString *)agency
{
    return @{newBrunswickAgency : @"New Brunswick", newarkAgency : @"Newark"}[agency];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // add multiple agency . Load information from both agencies ?
        self.agencyManagers = @{
                                newBrunswickAgency : [RUBusDataAgencyManager managerForAgency:newBrunswickAgency],
                                newarkAgency : [RUBusDataAgencyManager managerForAgency:newarkAgency]
                                };
        
    }
    return self;
}

// GET ALL ROUTES + STOPS
-(void)fetchAllStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler{
    [self.agencyManagers[agency] fetchAllStopsWithCompletion:handler];
}

-(void)fetchAllRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler
{
    [self.agencyManagers[agency] fetchAllRoutesWithCompletion:handler];
}


// GET ALL ACTIVE ROUTES + STOPS
-(void)fetchActiveStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler
{
    [self.agencyManagers[agency] fetchActiveStopsWithCompletion:handler];
}

-(void)fetchActiveRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler
{
    [self.agencyManagers[agency] fetchActiveRoutesWithCompletion:handler];
}

/*
 This searches through different agencies
 */
-(void) fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void (^)(NSArray *stops, NSError *error))handler
{
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *allStops = [NSMutableArray array];
    __block NSError *outerError;
    
    /*
     Load data for the different agency like NB and newark in different blocks.
     
     
     */
    [self.agencyManagers enumerateKeysAndObjectsUsingBlock:^
     (NSString *const agency, RUBusDataAgencyManager *agencyManager, BOOL *stop) // enumerate the dict , stop when stop is true
     {
         dispatch_group_enter(group);
         [agencyManager fetchActiveStopsNearbyLocation:location completion:^ // this function is called on the BusAgencyManager. Not recursion
          (NSArray *stops, NSError *error)
          {
              [allStops addObjectsFromArray:stops];
              if (error) outerError = error;
              dispatch_group_leave(group);
          }
          ];
     }];
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
                          {
                              handler(allStops,outerError);
                          });
}


#pragma mark - predictions api
-(void)getPredictionsForItem:(id)item completion:(void (^)(NSArray * ,  NSError *))handler
{
    // TEST :
    
    if(DEV)
    {
        NSString *urlTest = [self urlStringForItem:item];
        NSLog(@"%@" , urlTest);
    }
    
    NSString *url = [self urlStringForItem:item];
    RUBusRoute* tempRoute = nil;
    RUBusStop* tempStop = nil;
    RUBusDataAgencyManager* tempAgency = nil;
    if ([item isKindOfClass:[RUBusRoute class]]) {
        tempRoute = (RUBusRoute*)item;
        tempAgency = self.agencyManagers[tempRoute.agency];
    } else {
        tempStop = (RUBusStop*)item;
        tempAgency = self.agencyManagers[tempStop.agency];
    }
    [[RUNetworkManager transLocSessionManager] GET: url parameters: nil progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary* predictions = responseObject[@"data"];
            
            NSMutableArray *parsedPredictions = [NSMutableArray array];
            if ([predictions isKindOfClass:[NSArray class]]) {
                NSArray* predictionsCheck = (NSArray*)predictions;
                
                if ([predictionsCheck count] == 0) {
                    RUBusPrediction* noDataPrediction = [[RUBusPrediction alloc] init];
                    noDataPrediction.tempActive = NO;
                    if ([item isKindOfClass:[RUBusRoute class]]) {
                        RUBusRoute* cast = (RUBusRoute*)item;
                        for (RUBusVehicle* vehicle in tempAgency.vehicles[cast.route_id]) {
                               // if (vehicle.doesHaveArrivals == NO) {
                                    noDataPrediction.vehicle = vehicle;
                                //}
                        }
                        double distance = 1000000;
                        RUBusStop* savedStop = [RUBusStop alloc];
                        for (RUBusStop* stop in tempAgency.stops.allValues) {
                            double distanceTemp = [stop.location distanceFromLocation:noDataPrediction.vehicle.location];
                            if (distance > distanceTemp) {
                                distance = distanceTemp;
                                savedStop = stop;
                            }
                        }
                        
                        noDataPrediction.vehicle.nearbyStop = savedStop;
                    }
                    [parsedPredictions addObject:noDataPrediction];
                }
            }
           // if (parsedPredictions == nil) {
                for (NSDictionary* predictionItem in predictions) {
                    if ([item isKindOfClass:[RUBusRoute class]]) {
                        RUBusPrediction* predictionObj = [[RUBusPrediction alloc] initWithDictionary:predictionItem];
                        predictionObj.tempActive = YES;
                        predictionObj.routeTitle = tempRoute.title;
                        predictionObj.stopTitle = ((RUBusStop*)tempAgency.stops[predictionObj.stop_id]).title;
                        [parsedPredictions addObject:predictionObj];
                    } else {
                        NSArray* arrivalArray = [predictions valueForKey:@"arrivals"][0];
                        NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
                        for (NSDictionary* arrival in arrivalArray) {
                            NSString* routeId = (NSString*)[arrival valueForKey:@"route_id"];
                            int i = 0;
                            NSMutableArray* tempArrivalArray = [NSMutableArray array];
                            while (i < arrivalArray.count) {
                                NSDictionary* arrivalTemp = arrivalArray[i];
                                if (routeId == [arrivalTemp valueForKey:@"route_id"]) {
                                    RUBusArrival* arrivalObj = [[RUBusArrival alloc] initWithDictionary:arrivalTemp];
                                    [tempArrivalArray addObject:arrivalObj];
                                }
                                i++;
                            }
                            if ([tempDict objectForKey:routeId] == nil) {
                                [tempDict setObject:tempArrivalArray forKey:routeId];
                            }
                        }
                        for (NSString* key in [tempDict allKeys]) {
                            NSLog(@"%@", [tempDict objectForKey:key]);
                            RUBusPrediction* predictionObj = [[RUBusPrediction alloc] initWithArrivalArray:key arrivalArray:[tempDict objectForKey:key]];
                            predictionObj.tempActive = YES;
                            predictionObj.stopTitle = tempStop.title;
                            predictionObj.routeTitle = tempAgency.routes[key].title;
                            [parsedPredictions addObject:predictionObj];
                        }
                    }
                }
            //}
            handler(parsedPredictions, nil);
        } else {
            NSLog(@"Network request successful, cannot parse dictionary");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(nil, error);
    }];
}

-(NSString *)urlStringForItem:(id)item
{
    NSMutableString* urlBase = [[RUNetworkManager buildURLStringWith:@"arrival-estimates.json"] mutableCopy];
    [urlBase appendString:@"?agencies=1323&"];
    if ([item isKindOfClass:[RUBusRoute class]]) {
        RUBusRoute* route = (RUBusRoute*)item;
        NSMutableString* updatedUrl = [[urlBase stringByAppendingFormat:@"routes=%@&stops=", route.route_id] mutableCopy];
        
        for (NSString* stopId in route.stops) {
            [updatedUrl appendFormat:@"%@,", stopId];
        }
        return updatedUrl;
    } else {
        RUBusStop* stop = (RUBusStop*)item;
        NSString* stopId = [NSString stringWithFormat:@"%ld", (long) stop.stopId];
        return [urlBase stringByAppendingFormat:@"stops=%@", stopId];
    }
}

#pragma mark - nextBus to transloc transition



-(void)getArrivalEstimates {
    //    NSString* url = [self buildURLStringWith:@"arrival-estimates.json"];
    [[RUNetworkManager transLocSessionManager] GET: [RUNetworkManager buildURLStringWith:@"arrival-estimates.json"] parameters:[RUNetworkManager buildParameters: @""] progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Success!  Response object is a dictionary!");
            
        } else {
            NSLog(@"Network request successful, cannot parse dictionary");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure!");
    }];
}



#pragma mark - search
-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *routes, NSArray *stops, NSError *error))handler{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
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
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
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

-(void)performWhenAgencyLoaded:(void(^)(NSError *error))handler {
    __block NSError *outerError;
    
    dispatch_group_t group = dispatch_group_create();
    
    for (RUBusDataAgencyManager *manager in self.agencyManagers.allValues) {
        dispatch_group_enter(group);
        [manager performWhenAgencyLoaded:^(NSError *error) {
            if (error) outerError = error;
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        handler(outerError);
    });
}

/*
 Called when you access a favorited menu item, I'm guessing it deconstructs a deep link and returns the proper viewController
 */
-(void)getSerializedItemWithName:(NSString *)name type:(NSString *)type completion:(void (^)(id item, NSError *error))handler
{
    [self performWhenAgencyLoaded:^(NSError *error)
     {
         if (error)
         {
             handler(nil, error);
             return;
         }
         else
         {
             for (RUBusDataAgencyManager *manager in self.agencyManagers.allValues)
             {
                 id item = [manager reconstituteSerializedItemWithName:name type:type];
                 if (item)
                 {
                     handler(item, nil);
                     return;
                 }
             }
             handler(nil, nil);
             return;
         }
     }];
}
@end
