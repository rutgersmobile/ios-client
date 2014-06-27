//
//  RUPlacesData.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesData.h"
#import <AFNetworking.h>
#import "RULocationManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+FilterDictionary.h"
#import "RUPlace.h"

static NSString *const placesRecentPlacesKey = @"placesRecentPlacesKey";

@interface RUPlacesData ()
@property (nonatomic) NSDictionary *places;
@property dispatch_group_t placesGroup;

@end

@implementation RUPlacesData

+(RUPlacesData *)sharedInstance{
    static RUPlacesData *placesData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placesData = [[RUPlacesData alloc] init];
    });
    return placesData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{placesRecentPlacesKey: @[]}];
        self.placesGroup =  dispatch_group_create();
        dispatch_group_enter(self.placesGroup);
        [self getPlaces];
    }
    return self;
}

-(void)getPlaces{
    [[RUNetworkManager jsonSessionManager] GET:@"places.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self parsePlaces:responseObject];
            dispatch_group_leave(self.placesGroup);
        } else {
            [self getPlaces];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self getPlaces];
    }];
}
-(void)parsePlaces:(NSDictionary *)response{
   // NSArray *excludedCampuses = @[[NSNull null],@"off-campus",@"Off-Campus"];
    NSMutableDictionary *parsedPlaces = [NSMutableDictionary dictionary];
  //  NSMutableDictionary *sortedByLocation = [NSMutableDictionary dictionary];
    
    [response[@"all"] enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop) {
   //     if ([excludedCampuses containsObject:obj[@"campus_name"]]) return;
        RUPlace *place = [[RUPlace alloc] initWithDictionary:obj];
        parsedPlaces[place.uniqueID] = place;
        
        /*

        NSString *locationString = [NSString stringWithFormat:@"%f,%f",place.location.coordinate.latitude,place.location.coordinate.longitude];
        NSMutableArray *placesWithLocation = sortedByLocation[locationString];
        if (!placesWithLocation) {
            placesWithLocation = [NSMutableArray array];
            sortedByLocation[locationString] = placesWithLocation;
        }
        [placesWithLocation addObject:place];
        */
    }];
    /*
    NSArray *sortedArraysOfLocations = [[sortedByLocation allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger count1 = [obj1 count];
        NSInteger count2 = [obj2 count];
        if (count1 > count2) return NSOrderedAscending;
        if (count2 > count1) return NSOrderedDescending;
        return NSOrderedSame;
    }];*/
    
    self.places = parsedPlaces;
}

-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock{
    dispatch_group_notify(self.placesGroup, dispatch_get_main_queue(), ^{
        NSArray *results = [[self.places allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@",query]];
        
        NSPredicate *beginsWithPredicate = [NSPredicate predicateWithFormat:@"title beginswith[cd] %@",query];
        results = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BOOL one = [beginsWithPredicate evaluateWithObject:obj1];
            BOOL two = [beginsWithPredicate evaluateWithObject:obj2];
            if (one && !two) {
                return NSOrderedAscending;
            } else if (!one && two) {
                return NSOrderedDescending;
            }
            return [[obj1 title] compare:[obj2 title] options:NSNumericSearch|NSCaseInsensitiveSearch];
        }];
        
        completionBlock(results);
    });
}

-(void)getRecentPlacesWithCompletion:(void (^)(NSArray *recents))completionBlock{
    dispatch_group_notify(self.placesGroup, dispatch_get_main_queue(), ^{
        NSArray *recentPlaces = [[NSUserDefaults standardUserDefaults] arrayForKey:placesRecentPlacesKey];
        NSArray *recentPlacesDetails = [self.places objectsForKeys:recentPlaces notFoundMarker:[NSNull null]];
 
        recentPlacesDetails = [recentPlacesDetails filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if ([evaluatedObject isEqual:[NSNull null]]) return false;
            return true;
        }]];
        
        completionBlock(recentPlacesDetails);
    });
}

-(void)addPlaceToRecentPlacesList:(RUPlace *)place{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPlaces = [[userDefaults arrayForKey:placesRecentPlacesKey] mutableCopy];
    NSString *ID = place.uniqueID;
    if ([recentPlaces containsObject:ID]){
        [recentPlaces removeObject:ID];
    }
    [recentPlaces insertObject:ID atIndex:0];

    while (recentPlaces.count > MAX_RECENT_PLACES) {
        [recentPlaces removeLastObject];
    }
    
    [userDefaults setObject:recentPlaces forKey:placesRecentPlacesKey];
}

#pragma mark - nearby api
-(void)placesNearLocation:(CLLocation *)location completion:(void (^)(NSArray *nearbyPlaces))completionBlock{
    dispatch_group_notify(self.placesGroup, dispatch_get_main_queue(), ^{
        NSArray *nearbyPlaces = [[self.places allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            RUPlace *place = evaluatedObject;
            if (!place.location) return NO;
            return ([place.location distanceFromLocation:location] < NEARBY_DISTANCE);
        }]];
        
        nearbyPlaces = [nearbyPlaces sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            RUPlace *placeOne = obj1;
            RUPlace *placeTwo = obj2;

            CLLocationDistance distanceOne = [placeOne.location distanceFromLocation:location];
            CLLocationDistance distanceTwo = [placeTwo.location distanceFromLocation:location];
            
            if (distanceOne < distanceTwo) return NSOrderedAscending;
            else if (distanceOne > distanceTwo) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        if (nearbyPlaces.count > MAX_NEARBY_PLACES) {
            nearbyPlaces = [nearbyPlaces subarrayWithRange:NSMakeRange(0, MAX_NEARBY_PLACES)];
        }
        completionBlock([nearbyPlaces copy]);
    });
}
@end
