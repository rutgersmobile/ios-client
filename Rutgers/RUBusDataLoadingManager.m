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
#import "RUBusMultipleStopsForSingleLocation.h"
#import "RUBusPrediction.h"
#import "RUNetworkManager.h"
#import "RUDefines.h"

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
-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void (^)(NSArray *stops, NSError *error))handler
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
    
    
    [[RUNetworkManager sessionManager] GET:[self urlStringForItem:item] parameters:nil
        success:^
            (NSURLSessionDataTask *task, id responseObject)
            {
            
                if (![responseObject isKindOfClass:[NSDictionary class]]) // error : unable to serialize the object
                {
                    handler(nil,nil );
                    return;
                }
                
                id predictions = responseObject[@"predictions"]; // we get the prediction for each stop and we just display if for each site
                    // This contains prediction for stops in the route. The stops are requested using the api
                
                
                NSLog(@"%@",predictions);
                NSMutableArray *parsedPredictions = [NSMutableArray array];
               
                // create prediction objects
                for (NSDictionary *predictionDictionary in predictions) // obtain prediction for each stop
                {
                    RUBusPrediction *prediction = [[RUBusPrediction alloc] initWithDictionary:predictionDictionary];

                    
                    [parsedPredictions addObject:prediction];
                }
                
                if ([item isKindOfClass:[RUBusMultipleStopsForSingleLocation class]])
                {
                    [parsedPredictions filterUsingPredicate:[NSPredicate predicateWithFormat:@"active == %@",@YES]];
                    
                    //[parsedPredictions sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"active" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"routeTitle" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"directionTitle" ascending:YES]]];
                    
                    /*
                                Sort the result using multiple descritpors ..
                                    descritpors sorts the array by looking at a key in the dictionary
                         */
                    [parsedPredictions sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"routeTitle" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"directionTitle" ascending:YES]]];
                    
                }
                else if ([item isKindOfClass:[RUBusRoute class]]) // sort the predictions in a route using the
                {
                    RUBusRoute *route = item;
                    [parsedPredictions sortUsingComparator:^
                        NSComparisonResult(RUBusPrediction *obj1, RUBusPrediction *obj2)
                        {
                            NSInteger indexOne = [route.stops indexOfObject:obj1.stopTag];
                            NSInteger indexTwo = [route.stops indexOfObject:obj2.stopTag];
                            return compare(indexOne, indexTwo);
                        }
                     ];
                }
                
                handler(parsedPredictions,nil);
                
        
            }
        failure:^
            (NSURLSessionDataTask *task, NSError *error)
            {
                handler(nil,error);
            }
     ];
}

-(NSString *)urlStringForItem:(id)item
{
    NSString *agency = [item agency];
    return [self.agencyManagers[agency] urlStringForItem:item];
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
    WHAT DOES THIS DO ?
 
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
