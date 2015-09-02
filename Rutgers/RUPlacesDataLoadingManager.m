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
#import "RUDataLoadingManager_Private.h"

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
    }
    return self;
}

-(void)load{
    [self willBeginLoad];
    [[RUNetworkManager sessionManager] GET:@"places.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parsePlaces:responseObject];
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didEndLoad:NO withError:error];
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
    [self performWhenLoaded:^(NSError *error) {
        NSMutableOrderedSet *results = [NSMutableOrderedSet orderedSet];
        [results addObjectsFromArray:[self placesWithTitle:query]];
        [results addObjectsFromArray:[self placesWithOffice:query]];
        completionBlock([results.array sortByKeyPath:@"title"],error);
    }];
}

-(NSArray *)placesWithTitle:(NSString *)title{
    NSPredicate *searchPredicate = [NSPredicate predicateForQuery:title keyPath:@"title"];
    return [[self.places allValues] filteredArrayUsingPredicate:searchPredicate];
}

-(NSArray *)placesWithOffice:(NSString *)office{
    NSPredicate *officePredicate = [NSPredicate predicateForQuery:office keyPath:@"self"];
    NSPredicate *searchPredicate = [NSPredicate predicateWithBlock:^BOOL(RUPlace *place, NSDictionary *bindings) {
        for (NSString *office in place.offices) {
            if ([officePredicate evaluateWithObject:office]) return YES;
        }
        return NO;
    }];
    return [self.places.allValues filteredArrayUsingPredicate:searchPredicate];
}

-(void)getRecentPlacesWithCompletion:(void (^)(NSArray *recents, NSError *error))completionBlock{
    [self performWhenLoaded:^(NSError *error){
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
    
    [self performWhenLoaded:^(NSError *error) {
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
