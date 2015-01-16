//
//  RUPlacesData.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesDataLoadingManager.h"
#import <AFNetworking.h>
#import "RULocationManager.h"
#import "RUPlace.h"
#import "NSDictionary+ObjectsForKeys.h"
#import "NSArray+Sort.h"
#import "NSPredicate+SearchPredicate.h"
#import "NSArray+LimitedToCount.h"

NSString *PlacesDataDidUpdateRecentPlacesKey = @"PlacesDataDidUpdateRecentPlacesKey";
static NSString *const PlacesRecentPlacesKey = @"PlacesRecentPlacesKey";

@interface RUPlacesDataLoadingManager ()
@property (nonatomic) NSDictionary *places;

@property dispatch_group_t placesGroup;

@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;

@end

@implementation RUPlacesDataLoadingManager

+(RUPlacesDataLoadingManager *)sharedInstance{
    static RUPlacesDataLoadingManager *placesData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placesData = [[RUPlacesDataLoadingManager alloc] init];
    });
    return placesData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{PlacesRecentPlacesKey: @[]}];
        self.placesGroup =  dispatch_group_create();
    }
    return self;
}

-(BOOL)placesNeedLoad{
    return !(self.loading || self.finishedLoading);
}

-(void)performWhenPlacesLoaded:(void (^)(NSError *error))handler{
    if ([self placesNeedLoad]) {
        [self loadPlaces];
    }
    dispatch_group_notify(self.placesGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        handler(self.loadingError);
    });
}

-(void)loadPlaces{
    dispatch_group_enter(self.placesGroup);
    
    self.loading = YES;
    self.finishedLoading = NO;
    self.loadingError = nil;
    
    [[RUNetworkManager sessionManager] GET:@"places.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parsePlaces:responseObject];
        }
        
        self.loading = NO;
        self.finishedLoading = YES;
        self.loadingError = nil;
        
        dispatch_group_leave(self.placesGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        self.loading = NO;
        self.finishedLoading = NO;
        self.loadingError = error;
        
        dispatch_group_leave(self.placesGroup);
    }];
}

-(void)parsePlaces:(NSDictionary *)response{
    NSMutableDictionary *parsedPlaces = [NSMutableDictionary dictionary];
    
    [response[@"all"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        RUPlace *place = [[RUPlace alloc] initWithDictionary:obj];
        parsedPlaces[place.uniqueID] = place;
    }];

    self.places = parsedPlaces;
}

-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results, NSError *error))completionBlock{
    [self performWhenPlacesLoaded:^(NSError *error) {
        NSPredicate *searchPredicate = [NSPredicate predicateForQuery:query keyPath:@"title"];
        NSArray *results = [[self.places allValues] filteredArrayUsingPredicate:searchPredicate];
        results = [results sortByKeyPath:@"title"];
        completionBlock(results,error);
    }];
}

-(void)getRecentPlacesWithCompletion:(void (^)(NSArray *recents, NSError *error))completionBlock{
    [self performWhenPlacesLoaded:^(NSError *error){
        NSArray *recentPlaces = [[NSUserDefaults standardUserDefaults] arrayForKey:PlacesRecentPlacesKey];
        NSArray *recentPlacesDetails = [self.places objectsForKeysIgnoringNotFound:recentPlaces];
        completionBlock(recentPlacesDetails,error);
    }];
}

-(void)userWillViewPlace:(RUPlace *)place{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *recentPlaces = [[userDefaults arrayForKey:PlacesRecentPlacesKey] mutableCopy];
    
    NSString *ID = place.uniqueID;
    [recentPlaces removeObject:ID];
    [recentPlaces insertObject:ID atIndex:0];

    [userDefaults setObject:[recentPlaces limitedToCount:20] forKey:PlacesRecentPlacesKey];
    
    [self notifyRecentPlacesDidUpdate];
}

-(void)notifyRecentPlacesDidUpdate{
    [[NSNotificationCenter defaultCenter] postNotificationName:PlacesDataDidUpdateRecentPlacesKey object:self];
}

#pragma mark - nearby api
-(void)placesNearLocation:(CLLocation *)location completion:(void (^)(NSArray *nearbyPlaces, NSError *error))completionBlock{
    if (!location) {
        completionBlock(@[],nil);
        return;
    }
    
    [self performWhenPlacesLoaded:^(NSError *error) {
        NSArray *nearbyPlaces = [[[self.places allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RUPlace *place, NSDictionary *bindings) {
            if (!place.location) return NO;
            return ([place.location distanceFromLocation:location] < NEARBY_DISTANCE);
        }]] sortedArrayUsingComparator:^NSComparisonResult(RUPlace *placeOne, RUPlace *placeTwo) {
            
            CLLocationDistance distanceOne = [placeOne.location distanceFromLocation:location];
            CLLocationDistance distanceTwo = [placeTwo.location distanceFromLocation:location];
            
            if (distanceOne < distanceTwo) return NSOrderedAscending;
            else if (distanceOne > distanceTwo) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        completionBlock(nearbyPlaces,error);

    }];
}
@end
