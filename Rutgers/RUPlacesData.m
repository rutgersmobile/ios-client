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

        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        self.placesGroup = group;
        
        [self getPlaces];
    }
    return self;
}

-(void)getPlaces{
    [[RUNetworkManager jsonSessionManager] GET:@"https://rumobile.rutgers.edu/1/places.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
    NSArray *excludedCampuses = @[[NSNull null],@"off-campus",@"Off-Campus"];
    
    self.places = [response[@"all"] filteredDictionaryUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        id campusName = evaluatedObject[@"campus_name"];
        if ([excludedCampuses containsObject:campusName]) return NO;
        return YES;
    }]];
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
            return [obj1[@"title"] caseInsensitiveCompare:obj2[@"title"]];
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

-(void)addPlaceToRecentPlacesList:(NSDictionary *)place{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPlaces = [[userDefaults arrayForKey:placesRecentPlacesKey] mutableCopy];
    NSString *ID = place[@"id"];
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
            return ([locationOfPlace(evaluatedObject) distanceFromLocation:location] < NEARBY_DISTANCE);
        }]];
        
        nearbyPlaces = [nearbyPlaces sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CLLocationDistance distanceOne = [locationOfPlace(obj1) distanceFromLocation:location];
            CLLocationDistance distanceTwo = [locationOfPlace(obj2) distanceFromLocation:location];
            
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

CLLocation *locationOfPlace(NSDictionary * place){
    static NSMutableDictionary *locations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locations = [NSMutableDictionary dictionary];
    });
    
    NSString *ID = place[@"id"];
    CLLocation *location;
    if (locations[ID]){
        location = locations[ID];
    } else {
        location = [[CLLocation alloc] initWithLatitude:[place[@"location"][@"latitude"] doubleValue] longitude:[place[@"location"][@"longitude"] doubleValue]];
        if (location) {
            locations[ID] = location;
        } else {
            locations[ID] = [NSNull null];
        }
    }
    if (![location isEqual:[NSNull null]]) {
        return location;
    }
    return nil;
}
@end
