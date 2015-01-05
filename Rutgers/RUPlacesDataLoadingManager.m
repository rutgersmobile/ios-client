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
        dispatch_group_enter(self.placesGroup);
        [self getPlaces];
    }
    return self;
}

-(void)performOnPlacesLoaded:(void (^)(void))block{
    dispatch_group_notify(self.placesGroup, dispatch_get_main_queue(), block);
}

-(void)getPlaces{
    [[RUNetworkManager sessionManager] GET:@"places.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parsePlaces:responseObject];
            dispatch_group_leave(self.placesGroup);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getPlaces];
        });
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

-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock{
    dispatch_group_notify(self.placesGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPredicate *searchPredicate = [NSPredicate predicateForQuery:query keyPath:@"title"];
        NSArray *results = [[self.places allValues] filteredArrayUsingPredicate:searchPredicate];
        results = [results sortByKeyPath:@"title"];
        completionBlock(results);
    });
}

-(void)getRecentPlacesWithCompletion:(void (^)(NSArray *recents))completionBlock{
    [self performOnPlacesLoaded:^{
        NSArray *recentPlaces = [[NSUserDefaults standardUserDefaults] arrayForKey:PlacesRecentPlacesKey];
        NSArray *recentPlacesDetails = [self.places objectsForKeysIgnoringNotFound:recentPlaces];
        completionBlock(recentPlacesDetails);
    }];
}

-(void)userWillViewPlace:(RUPlace *)place{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *recentPlaces = [[userDefaults arrayForKey:PlacesRecentPlacesKey] mutableCopy];
    
    NSString *ID = place.uniqueID;
    if ([recentPlaces containsObject:ID]) [recentPlaces removeObject:ID];
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
    dispatch_group_notify(self.placesGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *nearbyPlaces = [[self.places allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RUPlace *place, NSDictionary *bindings) {
            if (!place.location) return NO;
            return ([place.location distanceFromLocation:location] < NEARBY_DISTANCE);
        }]];
        
        nearbyPlaces = [nearbyPlaces sortedArrayUsingComparator:^NSComparisonResult(RUPlace *placeOne, RUPlace *placeTwo) {

            CLLocationDistance distanceOne = [placeOne.location distanceFromLocation:location];
            CLLocationDistance distanceTwo = [placeTwo.location distanceFromLocation:location];
            
            if (distanceOne < distanceTwo) return NSOrderedAscending;
            else if (distanceOne > distanceTwo) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock([nearbyPlaces copy],nil);
        });
    });
}
@end
